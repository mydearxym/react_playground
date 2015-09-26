---
id: inline-styles-zh-CN
title: 行内样式
layout: tips
permalink: inline-styles-zh-CN.html
next: if-else-in-JSX.html
prev: introduction.html
---

在react中，行内样式并不是以字符串的形式出现，而是通过一个特定的样式对象来指定。在这个对象中，key值代表了用驼峰形式的样式名，而其对应的值则是样式值，通常来说这个值是个字符串([了解更多](/react/tips/style-props-value-px.html)):


```js
var divStyle = {
  color: 'white',
  backgroundImage: 'url(' + imgUrl + ')',
  WebkitTransition: 'all', // 注意这里的首字母'W'是大写
  msTransition: 'all' // 'ms'是唯一一个首字母需要小写的浏览器前缀
};

React.render(<div style={divStyle}>Hello World!</div>, mountNode);
```


样式的key用驼峰形式表示，是为了方便与JS中通过DOM节点获取样式属性的方式保持一致（比如 'node.style.backgroundImage'）。另外浏览器前缀[除了`ms`以外](http://www.andismith.com/blog/2012/02/modernizr-prefixed/) 首字母应该大写。想必因此`WebkitTransition`的首字母是“W”就不难理解了。