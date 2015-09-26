---
id: use-react-with-other-libraries
title: 与其他类库并行使用React
layout: tips
permalink: use-react-with-other-libraries.html
prev: children-undefined.html
next: dangerously-set-inner-html.html
---


你不用非得全部采用 React。组件的 [生命周期事件](/react/docs/component-specs.html#lifecycle-methods)，特别是`componentDidMount` 和 `componentDidUpdate`，非常适合放置其他类库的逻辑代码。

```js
var App = React.createClass({
  getInitialState: function() {
    return {myModel: new myBackboneModel({items: [1, 2, 3]})};
  },

  componentDidMount: function() {
    $(this.refs.placeholder.getDOMNode()).append($('<span />'));
  },

  componentWillUnmount: function() {
    // Clean up work here.
  },

  shouldComponentUpdate: function() {
    // Let's just never update this component again.
    return false;
  },

  render: function() {
    return <div ref="placeholder"/>;
  }
});

React.render(<App />, mountNode);
```

You can attach your own [event listeners](/react/tips/dom-event-listeners.html) and even [event streams](https://baconjs.github.io) this way.

你还可以通过这种方式来绑定你自己的 [事件监听（event listeners）](/react/tips/dom-event-listeners.html) 甚至是 [事件流（event streams）](https://baconjs.github.io)。
