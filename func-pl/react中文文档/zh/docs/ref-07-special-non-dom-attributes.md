---
id: special-non-dom-attributes
title: 特殊的非 DOM 属性
permalink: special-non-dom-attributes.html
prev: dom-differences.html
next: reconciliation.html
---

除了[与 DOM 的差异](/react/docs/dom-differences.html)之外，React 也提供了一些 DOM 里面不存在的属性。

- `key`：可选的唯一的标识器。当组件在`渲染`过程中被各种打乱的时候，由于差异检测逻辑，可能会被销毁后重新创建。给组件绑定一个 key，可以持续确保组件还存在 DOM 中。更多内容请参考[这里](/react/docs/multiple-components.html#dynamic-children)。
- `ref`：参考[这里](/react/docs/more-about-refs.html)。
- `dangerouslySetInnerHTML`：提供插入纯 HTML 字符串的功能，主要为了能和生成 DOM 字符串的库整合。更多内容请参考[这里](/react/tips/dangerously-set-inner-html.html)。
