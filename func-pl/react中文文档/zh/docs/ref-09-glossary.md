---
id: glossary
title: React （虚拟）DOM 术语
permalink: glossary.html
prev: reconciliation.html
---

在 React 的术语中，有五个核心类型，区分它们是很重要的：

- [ReactElement / ReactElement 工厂](#react-elements)
- [ReactNode](#react-nodes)
- [ReactComponent / ReactComponent 类](#react-components)

## React 元素

React 中最主要的类型就是 `ReactElement`。它有四个属性：`type`，`props`，`key` 和 `ref`。它没有方法，并且原型上什么都没有。

可以通过 `React.createElement` 创建该类型的一个实例。

```javascript
var root = React.createElement('div');
```

为了渲染一个新的树形结构到 DOM 中，你创建若干个 `ReactElement`，然后传给 `React.render` 作为第一个参数，同时将第二个参数设为一个正规的 DOM `元素` （`HTMLElement` 或者 `SVGElement`）。不要混淆 `ReactElement` 实例和 DOM `元素` 实例。一个 `ReactElement` 实例是一个轻量的，无状态的，不可变的，虚拟的 DOM `元素` 的表示。是一个虚拟 DOM。

```javascript
React.render(root, document.body);
```

要添加属性到 DOM 元素，把属性对象作为第二个参数传入 `React.render`，把子级作为第三个参数传给 `React.render`。

```javascript
var child = React.createElement('li', null, 'Text Content');
var root = React.createElement('ul', { className: 'my-list' }, child);
React.render(root, document.body);
```

如果使用 React JSX 语法，这些 `ReactElement` 实例自动创建。所以，如下代码是等价的：

```javascript
var root = <ul className="my-list">
             <li>Text Content</li>
           </ul>;
React.render(root, document.body);
```

__工厂__

一个 `ReactElement` 工厂就是一个简单的函数，该函数生成一个带有特殊 `type` 属性的 `ReactElement`。React 有一个内置的辅助方法用于创建工厂函数。事实上该方法就是这样的：

```javascript
function createFactory(type){
  return React.createElement.bind(null, type);
}
```

该函数能创建一个方便的短函数，而不是总调用 `React.createElement('div')`。

```javascript
var div = React.createFactory('div');
var root = div({ className: 'my-div' });
React.render(root, document.body);
```

React 已经内置了常用 HTML 标签的工厂函数：

```javascript
var root = React.DOM.ul({ className: 'my-list' },
             React.DOM.li(null, 'Text Content')
           );
```

如果使用 JSX 语法，就不需要工厂函数了。JSX 已经提供了一种方便的短函数来创建 `ReactElement` 实例。


## React 节点

一个 `ReactNode` 可以是：

- `ReactElement`
- `string` （又名 `ReactText`）
- `number` （又名 `ReactText`）
- `ReactNode` 实例数组 （又名 `ReactFragment`）

这些被用作其它 `ReactElement` 实例的属性，用于表示子级。实际上它们创建了一个 `ReactElement` 实例树。
（These are used as properties of other `ReactElement`s to represent children. Effectively they create a tree of `ReactElement`s.）


## React 组件

在使用 React 开发中，可以仅使用 `ReactElement` 实例，但是，要充分利用 React，就要使用 `ReactComponent` 来封装状态化的组件。

一个 `ReactComponent` 类就是一个简单的 JavaScript 类（或者说是“构造函数”）。

```javascript
var MyComponent = React.createClass({
  render: function() {
    ...
  }
});
```

当该构造函数调用的时候，应该会返回一个对象，该对象至少带有一个 `render` 方法。该对象指向一个 `ReactComponent` 实例。

```javascript
var component = new MyComponent(props); // never do this
```

除非为了测试，正常情况下不要自己调用该构造函数。React 帮你调用这个函数。

相反，把 `ReactComponent` 类传给 `createElement`，就会得到一个 `ReactElement` 实例。

```javascript
var element = React.createElement(MyComponent);
```

或者使用 JSX：

```javascript
var element = <MyComponent />;
```

当该实例传给 `React.render` 的时候，React 将会调用构造函数，然后创建并返回一个 `ReactComponent`。

```javascript
var component = React.render(element, document.body);
```

如果一直用相同的 `ReactElement` 类型和相同的 DOM `元素`容器调用 `React.render`，将会总是返回相同的实例。该实例是状态化的。

```javascript
var componentA = React.render(<MyComponent />, document.body);
var componentB = React.render(<MyComponent />, document.body);
componentA === componentB; // true
```

这就是为什么不应该创建你自己的实例。相反，在创建之前，`ReactElement` 是一个虚拟的 `ReactComponent`。新旧 `ReactElement` 可以比对，从而决定是创建一个新的 `ReactComponent` 实例还是重用已有的实例。

`ReactComponent` 的 `render` 方法应该返回另一个 `ReactElement`，这就允许组件被组装。
（The `render` method of a `ReactComponent` is expected to return another `ReactElement`. This allows these components to be composed. Ultimately the render resolves into `ReactElement` with a `string` tag which instantiates a DOM `Element` instance and inserts it into the document.）


## 正式的类型定义

__入口点（Entry Point）__

```
React.render = (ReactElement, HTMLElement | SVGElement) => ReactComponent;
```

__节点和元素（Nodes and Elements）__

```
type ReactNode = ReactElement | ReactFragment | ReactText;

type ReactElement = ReactComponentElement | ReactDOMElement;

type ReactDOMElement = {
  type : string,
  props : {
    children : ReactNodeList,
    className : string,
    etc.
  },
  key : string | boolean | number | null,
  ref : string | null
};

type ReactComponentElement<TProps> = {
  type : ReactClass<TProps>,
  props : TProps,
  key : string | boolean | number | null,
  ref : string | null
};

type ReactFragment = Array<ReactNode | ReactEmpty>;

type ReactNodeList = ReactNode | ReactEmpty;

type ReactText = string | number;

type ReactEmpty = null | undefined | boolean;
```

__类和组件（Classes and Components）__

```
type ReactClass<TProps> = (TProps) => ReactComponent<TProps>;

type ReactComponent<TProps> = {
  props : TProps,
  render : () => ReactElement
};
```

