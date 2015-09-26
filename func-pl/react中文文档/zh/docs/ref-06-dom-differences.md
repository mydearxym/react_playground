---
id: dom-differences
title: 与 DOM 的差异
permalink: dom-differences.html
prev: events.html
next: special-non-dom-attributes.html
---

React 为了性能和跨浏览器的原因，实现了一个独立于浏览器的事件和 DOM 系统。利用此功能，可以屏蔽掉一些浏览器的 DOM 的粗糙实现。

* 所有 DOM 的 properties 和 attributes （包括事件处理器）应该都是驼峰命名的，以便和标准的 JavaScript 风格保持一致。我们故意和规范不同，因为规范本身就不一致。**然而**，`data-*` 和 `aria-*` 属性[符合规范](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes#data-*)，应该仅是小写的。
* `style` 属性接收一个带有驼峰命名风格的 JavaScript 对象，而不是一个 CSS 字符串。这与 DOM 中的 `style` 的 JavaScript 属性保持一致，更加有效，并且弥补了 XSS 安全漏洞。
* 所有的事件对象和 W3C 规范保持一致，并且所有的事件（包括提交事件）冒泡都正确地遵循 W3C 规范。参考[事件系统](/react/docs/events.html)获取更多详细信息。
* `onChange` 事件表现得和你想要的一样：当表单字段改变了，该事件就被触发，而不是等到失去焦点的时候。我们故意和现有的浏览器表现得不一致，是因为 `onChange` 是它的行为的一个错误称呼，并且 React 依赖于此事件来实时地响应用户输入。参考[表单](/react/docs/forms.html)获取更多详细信息。
* 表单输入属性，例如 `value` 和 `checked`，以及 `textarea`。[这里有更多相关信息](/react/docs/forms.html)。
