---
id: top-level-api
title: 顶层API
permalink: top-level-api.html
next: component-api.html
redirect_from: "/docs/reference.html"
---

## React

`React` 是 React 库的入口。如果使用的是预编译包，则 `React` 是全局的；如果使用 CommonJS 模块系统，则可以用 `require()` 函数引入 React。


### React.createClass

```javascript
ReactClass createClass(object specification)
```

创建一个组件类，并作出定义。组件实现了 `render()` 方法，该方法返回**一个**子级。该子级可能包含很深的子级结构。组件与标准原型类的不同之处在于，你不需要使用 new 来实例化。 组件是一种很方便的封装，可以（通过 new ）为你创建后台实例。

更多关于定义组件对象的信息，参考[组件定义和生命周期](/react/docs/component-specs.html)。


### React.createElement

```javascript
ReactElement createElement(
  string/ReactClass type,
  [object props],
  [children ...]
)
```

创建并返回一个新的指定类型的 `ReactElement`。type 参数可以是一个 html 标签名字字符串（例如，“div”，“span”，等等），或者是 `ReactClass` （通过 `React.createClass` 创建的）。


### React.createFactory

```javascript
factoryFunction createFactory(
  string/ReactClass type
)
```

返回一个生成指定类型 ReactElements 的函数。比如 `React.createElement`，type 参数可以是一个 html 标签名字字符串（例如，“div”，“span”，等等），或者是 `ReactClass`。


### React.render

```javascript
ReactComponent render(
  ReactElement element,
  DOMElement container,
  [function callback]
)
```

渲染一个 ReactElement 到 DOM 中，放在 `container` 指定的 DOM 元素下，返回一个到该组件的引用。

如果 ReactElement 之前就被渲染到了 `container` 中，该函数将会更新此 ReactElement，仅改变需要改变的 DOM 节点以展示最新的 React 组件。

如果提供了可选的回调函数，则该函数将会在组件渲染或者更新之后调用。

> 注意：
>
> `React.render()` 替换传入的容器节点内容。在将来，或许可能插入组件到已存在的 DOM 节点中，但不覆盖已有的子节点。


### React.unmountComponentAtNode

```javascript
boolean unmountComponentAtNode(DOMElement container)
```

从 DOM 中移除已经挂载的 React 组件，清除相应的事件处理器和 state。如果在 container 内没有组件挂载，这个函数将什么都不做。如果组件成功移除，则返回 `true`；如果没有组件被移除，则返回 `false`。


### React.renderToString

```javascript
string renderToString(ReactElement element)
```

把组件渲染成原始的 HTML 字符串。该方法应该仅在服务器端使用。React 将会返回一个 HTML 字符串。你可以在服务器端用此方法生成 HTML，然后将这些标记发送给客户端，这样可以获得更快的页面加载速度，并且有利于搜索引擎抓取页面，方便做 SEO。

如果在一个节点上面调用 `React.render()`，并且该节点已经有了服务器渲染的标记，React 将会维护该节点，并且仅绑定事件处理器，保证有一个高效的首屏加载体验。


### React.renderToStaticMarkup

```javascript
string renderToStaticMarkup(ReactElement element)
```

和 `renderToString` 类似，除了不创建额外的 DOM 属性，例如 `data-react-id`，因为这些属性仅在 React 内部使用。如果你想用 React 做一个简单的静态页面生成器，这是很有用的，因为丢掉额外的属性能够节省很多字节。


### React.isValidElement

```javascript
boolean isValidElement(* object)
```

判断对象是否是一个 ReactElement。


### React.DOM

`React.DOM` 运用 `React.createElement` 为 DOM 组件提供了方便的包装。该方式仅在未使用 JSX 的时候适用。例如，`React.DOM.div(null, 'Hello World!')`。


### React.PropTypes

`React.PropTypes` 包含了能与组件 `propTypes` 对象共用的类型，用于验证传入组件的 props。更多有关 `propTypes` 的信息，参考[复用组件](/react/docs/reusable-components.html)。


### React.initializeTouchEvents

```javascript
initializeTouchEvents(boolean shouldUseTouch)
```

配置 React 的事件系统，使 React 能处理移动设备的触摸（ touch ）事件。


### React.Children

`React.Children` 为处理 `this.props.children` 这个封闭的数据结构提供了有用的工具。

#### React.Children.map

```javascript
object React.Children.map(object children, function fn [, object context])
```

在每一个直接子级（包含在 `children` 参数中的）上调用 `fn` 函数，此函数中的 `this` 指向 `上下文`。如果 `children` 是一个内嵌的对象或者数组，它将被遍历：不会传入容器对象到 `fn` 中。如果 children 参数是 `null` 或者 `undefined`，那么返回 `null` 或者 `undefined` 而不是一个空对象。

#### React.Children.forEach

```javascript
React.Children.forEach(object children, function fn [, object context])
```

类似于 `React.Children.map()`，但是不返回对象。

#### React.Children.count

```javascript
number React.Children.count(object children)
```

返回 `children` 当中的组件总数，和传递给 `map` 或者 `forEach` 的回调函数的调用次数一致。

#### React.Children.only

```javascript
object React.Children.only(object children)
```

返回 `children` 中仅有的子级。否则抛出异常。
