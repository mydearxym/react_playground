---
id: references-to-components
title: 组件的引用
layout: tips
permalink: references-to-components.html
prev: expose-component-functions.html
next: children-undefined.html
---

如果你正在一个大型的非 React 应用里使用 React 组件，或者准备将你的代码转换成 React，你可能需要保持组件的引用。 `React.render` 会返回一个渲染后的组件的引用：

```js
var myComponent = React.render(<MyComponent />, myContainer);
```

记住，JSX 并不会返回组件的引用！ 它只是一个 **ReactElement** : 一个用来告知 React 渲染后的组件应该长什么样子的轻便的标识符。

```js
var myComponentElement = <MyComponent />; // 只是 ReactElement.

// Some code here...

var myComponentInstance = React.render(myComponentElement, myContainer);
```

> 注意：
>
> 这中引用只能在最顶层级使用。 在组件内部，让 `props` 和 `state` 来处理组件间的通信，而且只能通过 [refs](http://facebook.github.io/react/docs/more-about-refs.html). 来引用。
