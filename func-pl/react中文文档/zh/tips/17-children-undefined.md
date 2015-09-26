---
id: children-undefined
title: this.props.children undefined
layout: tips
permalink: children-undefined.html
prev: references-to-components.html
next: use-react-with-other-libraries.html
---


你没办法通过 `this.props.children` 取得当前组件的子元素。 因为`this.props.children` 返回的是组件拥有者传递给你的 **passed onto you** 子节点。

```js
var App = React.createClass({
  componentDidMount: function() {
    // This doesn't refer to the `span`s! It refers to the children between
    // last line's `<App></App>`, which are undefined.
    console.log(this.props.children);
  },

  render: function() {
    return <div><span/><span/></div>;
  }
});

React.render(<App></App>, mountNode);
```

如果想看更多地例子， 可以参考在 [front page](/) 里最后一个例子。
