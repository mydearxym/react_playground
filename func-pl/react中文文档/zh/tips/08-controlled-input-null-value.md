---
id: controlled-input-null-value
title: Controlled Input 值为 null 的情况
layout: tips
permalink: controlled-input-null-value.html
prev: children-props-type.html
next: componentWillReceiveProps-not-triggered-after-mounting.html
---

为每个[controlled component](/react/docs/forms.html)指定 `value` 属性，来防止用户修改输入除非你希望如此。


你也许会遇到这种问题：虽然已经指定了 `value` ，但是 input 依然可以未经允许就改变。这种情况，可能是因为一不小将 `value` 设置成了 `undefined` 或 `null`。


下面这条代码片段展示了这个现象，一秒钟之后，文本变得可编辑了。

```js
React.render(<input value="hi" />, mountNode);

setTimeout(function() {
  React.render(<input value={null} />, mountNode);
}, 1000);
```
