---
id: children-props-type
title: 子 props 的类型
layout: tips
permalink: children-props-type.html
prev: style-props-value-px.html
next: controlled-input-null-value.html
---

通常，一个组件的子代（`this.props.children`）是一个组件的数组：

```js
var GenericWrapper = React.createClass({
  componentDidMount: function() {
    console.log(Array.isArray(this.props.children)); // => true
  },

  render: function() {
    return <div />;
  }
});

React.render(
  <GenericWrapper><span/><span/><span/></GenericWrapper>,
  mountNode
);
```

然而，当只有一个子代的时候，`this.props.children` 将会变成一个单独的组件，而不是_数组形式_。这样就减少了数组的占用。

```js
var GenericWrapper = React.createClass({
  componentDidMount: function() {
    console.log(Array.isArray(this.props.children)); // => false

    // 注意：结果将是 5，而不是 1，因为 `this.props.children` 不是数组，而是 'hello' 字符串！
    console.log(this.props.children.length);
  },

  render: function() {
    return <div />;
  }
});

React.render(<GenericWrapper>hello</GenericWrapper>, mountNode);
```

为了让处理 `this.props.children` 更简单，我们提供了 [React.Children utilities](/react/docs/top-level-api.html#react.children) 。
