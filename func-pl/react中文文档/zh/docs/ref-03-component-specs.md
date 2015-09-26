---
id: component-specs
title: 组件的详细说明和生命周期（Component Specs and Lifecycle）
permalink: component-specs.html
prev: component-api.html
next: tags-and-attributes.html
---

## 组件的详细说明（Component Specifications）

当通过调用 `React.createClass()` 来创建组件的时候，你应该提供一个包含 `render` 方法的对象，并且也可以包含其它的在这里描述的生命周期方法。

### render

```javascript
ReactComponent render()
```

`render()` 方法是必须的。

当调用的时候，会检测 `this.props` 和 `this.state`，返回一个单子级组件。该子级组件可以是虚拟的本地 DOM 组件（比如 `<div />` 或者 `React.DOM.div()`），也可以是自定义的复合组件。

你也可以返回 `null` 或者 `false` 来表明不需要渲染任何东西。实际上，React 渲染一个 `<noscript>` 标签来处理当前的差异检查逻辑。当返回 `null` 或者 `false` 的时候，`this.getDOMNode()` 将返回 `null`。

`render()` 函数应该是*纯粹的*，也就是说该函数不修改组件 state，每次调用都返回相同的结果，不读写 DOM 信息，也不和浏览器交互（例如通过使用 `setTimeout`）。如果需要和浏览器交互，在 `componentDidMount()` 中或者其它生命周期方法中做这件事。保持 `render()` 纯粹，可以使服务器端渲染更加切实可行，也使组件更容易被理解。


### getInitialState

```javascript
object getInitialState()
```

在组件挂载之前调用一次。返回值将会作为 `this.state` 的初始值。


### getDefaultProps

```javascript
object getDefaultProps()
```

在组件类创建的时候调用一次，然后返回值被缓存下来。如果父组件没有指定 props 中的某个键，则此处返回的对象中的相应属性将会合并到 `this.props` （使用 `in` 检测属性）。

该方法在任何实例创建之前调用，因此不能依赖于 `this.props`。另外，`getDefaultProps()` 返回的任何复杂对象将会在实例间共享，而不是每个实例拥有一份拷贝。


### propTypes

```javascript
object propTypes
```

`propTypes` 对象允许验证传入到组件的 props。更多关于 `propTypes` 的信息，参考[可重用的组件](/react/docs/reusable-components.html)。


### mixins

```javascript
array mixins
```

`mixin` 数组允许使用混合来在多个组件之间共享行为。更多关于混合的信息，参考[可重用的组件](/react/docs/reusable-components.html)。


### statics

```javascript
object statics
```

`statics` 对象允许你定义静态的方法，这些静态的方法可以在组件类上调用。例如：

```javascript
var MyComponent = React.createClass({
  statics: {
    customMethod: function(foo) {
      return foo === 'bar';
    }
  },
  render: function() {
  }
});

MyComponent.customMethod('bar');  // true
```

在这个块儿里面定义的方法都是静态的，意味着你可以在任何组件实例创建之前调用它们，这些方法不能获取组件的 props 和 state。如果你想在静态方法中检查 props 的值，在调用处把 props 作为参数传入到静态方法。


### displayName

```javascript
string displayName
```

`displayName` 字符串用于输出调试信息。JSX 自动设置该值；参考[JSX 深入](/react/docs/jsx-in-depth.html#react-composite-components)。


## 生命周期方法

许多方法在组件生命周期中某个确定的时间点执行。


### 挂载： componentWillMount

```javascript
componentWillMount()
```

服务器端和客户端都只调用一次，在初始化渲染执行之前立刻调用。如果在这个方法内调用 `setState`，`render()` 将会感知到更新后的 state，将会执行仅一次，尽管 state 改变了。


### 挂载： componentDidMount

```javascript
componentDidMount()
```

在初始化渲染执行之后立刻调用一次，仅客户端有效（服务器端不会调用）。在生命周期中的这个时间点，组件拥有一个 DOM 展现，你可以通过 `this.getDOMNode()` 来获取相应 DOM 节点。

如果想和其它 JavaScript 框架集成，使用 `setTimeout` 或者 `setInterval` 来设置定时器，或者发送 AJAX 请求，可以在该方法中执行这些操作。

> 注意：
>
> 为了兼容 v0.9，DOM 节点作为最后一个参数传入。你依然可以通过 `this.getDOMNode()` 获取 DOM 节点。


### 更新： componentWillReceiveProps

```javascript
componentWillReceiveProps(object nextProps)
```

在组件接收到新的 props 的时候调用。在初始化渲染的时候，该方法不会调用。

用此函数可以作为 react 在 prop 传入之后， `render()` 渲染之前更新 state 的机会。老的 props 可以通过 `this.props` 获取到。在该函数中调用 `this.setState()` 将不会引起第二次渲染。

```javascript
componentWillReceiveProps: function(nextProps) {
  this.setState({
    likesIncreasing: nextProps.likeCount > this.props.likeCount
  });
}
```

> 注意：
>
> 对于 state，没有相似的方法： `componentWillReceiveState`。将要传进来的 prop 可能会引起 state 改变，反之则不然。如果需要在 state 改变的时候执行一些操作，请使用 `componentWillUpdate`。


### 更新： shouldComponentUpdate

```javascript
boolean shouldComponentUpdate(object nextProps, object nextState)
```

在接收到新的 props 或者 state，将要渲染之前调用。该方法在初始化渲染的时候不会调用，在使用 `forceUpdate` 方法的时候也不会。

如果确定新的 props 和 state 不会导致组件更新，则此处应该 `返回 false`。

```javascript
shouldComponentUpdate: function(nextProps, nextState) {
  return nextProps.id !== this.props.id;
}
```

如果 `shouldComponentUpdate` 返回 false，则 `render()` 将不会执行，直到下一次 state 改变。（另外，`componentWillUpdate` 和 `componentDidUpdate` 也不会被调用。）

默认情况下，`shouldComponentUpdate` 总会返回 true，在 `state` 改变的时候避免细微的 bug，但是如果总是小心地把 `state` 当做不可变的，在 `render()` 中只从 `props` 和 `state` 读取值，此时你可以覆盖 `shouldComponentUpdate` 方法，实现新老 props 和 state 的比对逻辑。

如果性能是个瓶颈，尤其是有几十个甚至上百个组件的时候，使用 `shouldComponentUpdate` 可以提升应用的性能。


### 更新： componentWillUpdate

```javascript
componentWillUpdate(object nextProps, object nextState)
```

在接收到新的 props 或者 state 之前立刻调用。在初始化渲染的时候该方法不会被调用。

使用该方法做一些更新之前的准备工作。

> 注意：
>
> 你*不能*在刚方法中使用 `this.setState()`。如果需要更新 state 来响应某个 prop 的改变，请使用 `componentWillReceiveProps`。


### 更新： componentDidUpdate

```javascript
componentDidUpdate(object prevProps, object prevState)
```

在组件的更新已经同步到 DOM 中之后立刻被调用。该方法不会在初始化渲染的时候调用。

使用该方法可以在组件更新之后操作 DOM 元素。

> 注意：
>
> 为了兼容 v0.9，DOM 节点会作为最后一个参数传入。如果使用这个方法，你仍然可以使用 `this.getDOMNode()` 来访问 DOM 节点。


### 移除： componentWillUnmount

```javascript
componentWillUnmount()
```

在组件从 DOM 中移除的时候立刻被调用。

在该方法中执行任何必要的清理，比如无效的定时器，或者清除在 `componentDidMount` 中创建的 DOM 元素。
