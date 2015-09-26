---
id: componentWillReceiveProps-not-triggered-after-mounting
title: Mounting 后 componentWillReceiveProps 未被触发
layout: tips
permalink: componentWillReceiveProps-not-triggered-after-mounting.html
prev: controlled-input-null-value.html
next: props-in-getInitialState-as-anti-pattern.html
---


当节点初次被放入的时候 `componentWillReceiveProps` 并不会被触发。这是故意这么设计的。查看更多 [其他生命周期的方法](/react/docs/component-specs.html) 。

原因是因为 `componentWillReceiveProps` 经常会处理一些和 old props 比较的逻辑，而且会在变化之前执行；不在组件即将渲染的时候触发，这也是这个方法设计的初衷。