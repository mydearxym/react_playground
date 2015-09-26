---
id: addons
title: 插件
permalink: addons.html
prev: tooling-integration.html
next: animation.html
---

`React.addons` 是为了构建 React 应用而放置的一些有用工具的地方。**此功能应当被视为实验性的**，但最终将会被添加进核心代码中或者有用的工具库中：

- [`TransitionGroup`和`CSSTransitionGroup`](animation.html)，用于处理动画和过渡，这些通常实现起来都不简单，例如在一个组件移除之前执行一段动画。
- [`LinkedStateMixin`](two-way-binding-helpers.html)，用于简化用户表单输入数据和组件 state 之间的双向数据绑定。
- [`classSet`](class-name-manipulation.html)，用于更加干净简洁地操作 DOM 中的 `class` 字符串。
- [`cloneWithProps`](clone-with-props.html)，用于实现 React 组件浅复制，同时改变它们的 props 。
- [`update`](update.html)，一个辅助方法，使得在 JavaScript 中处理不可变数据更加容易。
- [`PureRednerMixin`](pure-render-mixin.html)，在某些场景下的性能检测器。

以下插件只存在于 React 开发版（未压缩）：

- [`TestUtils`](test-utils.html)， 简单的辅助工具，用于编写测试用例（仅存在于未压缩版）.
- [`Perf`](perf.html)，用于性能测评，并帮助你检查出可优化的功能点。

要使用这些插件，需要用 `react-with-addons.js` （和它的最小化副本）替换常规的`React.js`。

当通过npm使用react包的时候，只要简单地用 `require('react/addons')` 替换 `require('react')` 来得到带有所有插件的React。
