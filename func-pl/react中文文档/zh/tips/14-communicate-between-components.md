---
id: communicate-between-components
title: 组件间的通信
layout: tips
permalink: communicate-between-components.html
prev: false-in-jsx.html
next: expose-component-functions.html
---


对于 父-子 通信，直接 [pass props](/react/docs/multiple-components.html).


对于 子-父 通信：
例如： `GroceryList` 组件有一些通过数组生成的子节点。当这些节点被点击的时候，你想要展示这个节点的名字：

```js
var GroceryList = React.createClass({
  handleClick: function(i) {
    console.log('You clicked: ' + this.props.items[i]);
  },

  render: function() {
    return (
      <div>
        {this.props.items.map(function(item, i) {
          return (
            <div onClick={this.handleClick.bind(this, i)} key={i}>{item}</div>
          );
        }, this)}
      </div>
    );
  }
});

React.render(
  <GroceryList items={['Apple', 'Banana', 'Cranberry']} />, mountNode
);
```


注意 `bind(this, arg1, arg2, ...)` 的使用： 我们通过它向 `handleClick` 传递参数。 这不是 React 的新概念，而是 JavaScript 的。


对于没有 父-子 关系的组件间的通信，你可以设置你自己的全局事件系统。 在 `componentDidMount()` 里订阅事件，在 `componentWillUnmount()` 里退订，然后在事件回调里调用 `setState()`。
