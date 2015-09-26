---
id: component-api
title: 组件 API
permalink: component-api.html
prev: top-level-api.html
next: component-specs.html
---

## ReactComponent

React 组件实例在渲染的时候创建。这些实例在接下来的渲染中被重复使用，可以在组件方法中通过 `this` 访问。唯一一种在 React 之外获取 React 组件实例句柄的方式就是保存 `React.render` 的返回值。在其它组件内，可以使用 [refs](/react/docs/more-about-refs.html) 得到相同的结果。


### setState

```javascript
setState(object nextState[, function callback])
```

合并 nextState 和当前 state。这是在事件处理函数中和请求回调函数中触发 UI 更新的主要方法。另外，也支持可选的回调函数，该函数在 `setState` 执行完毕并且组件重新渲染完成之后调用。

> 注意：
>
> *绝对不要*直接改变 `this.state`，因为在之后调用 `setState()` 可能会替换掉你做的更改。把 `this.state` 当做不可变的。
>
> `setState()` 不会立刻改变 `this.state`，而是创建一个即将处理的 state 转变。在调用该方法之后获取 `this.state` 的值可能会得到现有的值，而不是最新设置的值。
>
> 不保证 `setState()` 调用的同步性，为了提升性能，可能会批量执行 state 转变和 DOM 渲染。
>
> `setState()` 将总是触发一次重绘，除非在 `shouldComponentUpdate()` 中实现了条件渲染逻辑。如果使用可变的对象，但是又不能在 `shouldComponentUpdate()` 中实现这种逻辑，仅在新 state 和之前的 state 存在差异的时候调用 `setState()` 可以避免不必要的重新渲染。


### replaceState

```javascript
replaceState(object nextState[, function callback])
```

类似于 `setState()`，但是删除之前所有已存在的 state 键，这些键都不在 nextState 中。


### forceUpdate()

```javascript
forceUpdate([function callback])
```

如果 `render()` 方法从 `this.props` 或者 `this.state` 之外的地方读取数据，你需要通过调用 `forceUpdate()` 告诉 React 什么时候需要再次运行 `render()`。如果直接改变了 `this.state`，也需要调用 `forceUpdate()`。

调用 `forceUpdate()` 将会导致 `render()` 方法在相应的组件上被调用，并且子级组件也会调用自己的 `render()`，但是如果标记改变了，那么 React 仅会更新 DOM。

通常情况下，应该尽量避免所有使用 `forceUpdate()` 的情况，在 `render()` 中仅从 `this.props` 和 `this.state` 中读取数据。这会使应用大大简化，并且更加高效。


### getDOMNode

```javascript
DOMElement getDOMNode()
```

如果组件已经挂载到了 DOM 上，该方法返回相应的本地浏览器 DOM 元素。从 DOM 中读取值的时候，该方法很有用，比如获取表单字段的值和做一些 DOM 操作。当 `render` 返回 `null` 或者 `false` 的时候，`this.getDOMNode()` 返回 `null`。


### isMounted()

```javascript
bool isMounted()
```

如果组件渲染到了 DOM 中，`isMounted()` 返回 true。可以使用该方法保证 `setState()` 和 `forceUpdate()` 在异步场景下的调用不会出错。


### setProps

```javascript
setProps(object nextProps[, function callback])
```

当和一个外部的 JavaScript 应用集成的时候，你可能想给一个用 `React.render()` 渲染的组件打上改变的标记。

尽管在同一个节点上再次调用 `React.render()` 来更新根组件是首选的方式，也可以调用 `setProps()` 来改变组件的属性，触发一次重新渲染。另外，可以传递一个可选的回调函数，该函数将会在 `setProps` 完成并且组件重新渲染完成之后调用。

> 注意：
>
> When possible, the declarative approach of calling `React.render()` again is preferred; it tends to make updates easier to reason about. (There's no significant performance difference between the two approaches.)
>
> 刚方法仅在根组件上面调用。也就是说，仅在直接传给 `React.render()` 的组件上可用，在它的子级组件上不可用。如果你倾向于在子组件上使用 `setProps()`，不要利用响应式更新，而是当子组件在 `render()` 中创建的时候传入新的 prop 到子组件中。


### replaceProps

```javascript
replaceProps(object nextProps[, function callback])
```

类似于 `setProps()`，但是删除所有已存在的 props，而不是合并新旧两个 props 对象。
