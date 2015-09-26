---
id: reconciliation
title: Reconciliation
permalink: reconciliation.html
prev: special-non-dom-attributes.html
next: glossary.html
---

React 的关键设计目标是使 API 看起来就像每一次有数据更新的时候，整个应用重新渲染了一样。这就极大地简化了应用的编写，但是同时使 React 易于驾驭，也是一个很大的挑战。这篇文章解释了我们如何使用强大的试探法来将 O(n<sup>3</sup>) 复杂度的问题转换成 O(n) 复杂度的问题。


## 动机（Motivation）

生成最少的将一颗树形结构转换成另一颗树形结构的操作，是一个复杂的，并且值得研究的问题。[最优算法](http://grfia.dlsi.ua.es/ml/algorithms/references/editsurvey_bille.pdf)的复杂度是 O(n<sup>3</sup>)，n 是树中节点的总数。

这意味着要展示1000个节点，就要依次执行上十亿次的比较。这对我们的使用场景来说太昂贵了。准确地感受下这个数字：现今的 CPU 每秒钟能执行大约三十亿条指令。因此即便是最高效的实现，也不可能在一秒内计算出差异情况。

既然最优的算法都不好处理这个问题，我们实现一个非最优的 O(n) 算法，使用试探法，基于如下两个假设：

1、拥有相同类的两个组件将会生成相似的树形结构，拥有不同类的两个组件将会生成不同的树形结构。<br>
2、可以为元素提供一个唯一的标志，该元素在不同的渲染过程中保持不变。

实际上，这些假设会使在几乎所有的应用场景下，应用变得出奇地快。


## 两个节点的差异检查（Pair-wise diff）

为了进行一次树结构的差异检查，首先需要能够检查两个节点的差异。此处有三种不同的情况需要处理：


### 不同的节点类型

如果节点的类型不同，React 将会把它们当做两个不同的子树，移除之前的那棵子树，然后创建并插入第二棵子树。

```xml
renderA: <div />
renderB: <span />
=> [removeNode <div />], [insertNode <span />]
```

该方法也同样应用于传统的组件。如果它们不是相同的类型，React 甚至将不会尝试计算出该渲染什么，仅会从 DOM 中移除之前的节点，然后插入新的节点。

```xml
renderA: <Header />
renderB: <Content />
=> [removeNode <Header />], [insertNode <Content />]
```

具备这种高级的知识点对于理解为什么 React 的差异检测逻辑既快又精确是很重要的。它对于避开树形结构大部分的检测，然后聚焦于似乎相同的部分，提供了启发。

一个 `<Header>` 元素与一个 `<Content>` 元素生成的 DOM 结构不太可能一样。React 将重新创建树形结构，而不是耗费时间去尝试匹配这两个树形结构。

如果在两个连续的渲染过程中的相同位置都有一个 `<Header>` 元素，将会希望生成一个非常相似的 DOM 结构，因此值得去做一做匹配。


### DOM 节点

当比较两个 DOM 节点的时候，我们查看两者的属性，然后能够找出哪一个属性随着时间产生了变化。

```xml
renderA: <div id="before" />
renderB: <div id="after" />
=> [replaceAttribute id "after"]
```

React 不会把 style 当做难以操作的字符串，而是使用键值对对象。这就很容易地仅更新改变了的样式属性。

```xml
renderA: <div style={{'{{'}}color: 'red'}} />
renderB: <div style={{'{{'}}fontWeight: 'bold'}} />
=> [removeStyle color], [addStyle font-weight 'bold']
```

在属性更新完毕之后，递归检测所有的子级的属性。


### 自定义组件

我们决定两个自定义组件是相同的。因为组件是状态化的，不可能每次状态改变都要创建一个新的组件实例。React 利用新组件上的所有属性，然后在之前的组件实例上调用 `component[Will/Did]ReceiveProps()`。

现在，之前的组件就是可操作了的。它的 `render()` 方法被调用，然后差异算法重新比较新的状态和上一次的状态。


## 子级优化差异算法（List-wise diff）

### 问题点（Problematic Case）

为了完成子级更新，React 选用了一种很原始的方法。React 同时遍历两个子级列表，当发现差异的时候，就产生一次 DOM 修改。

例如在末尾添加一个元素：

```xml
renderA: <div><span>first</span></div>
renderB: <div><span>first</span><span>second</span></div>
=> [insertNode <span>second</span>]
```

在开始处插入元素比较麻烦。React 发现两个节点都是 span，因此直接修改已有 span 的文本内容，然后在后面插入一个新的 span 节点。

```xml
renderA: <div><span>first</span></div>
renderB: <div><span>second</span><span>first</span></div>
=> [replaceAttribute textContent 'second'], [insertNode <span>first</span>]
```

有很多的算法尝试找出变换一组元素的最小操作集合。[Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance)算法能够找出这个最小的操作集合，使用单一元素插入、删除和替换，复杂度为 O(n<sup>2</sup>) 。即使使用 Levenshtein 算法，不会检测出一个节点已经移到了另外一个位置去了，要实现这个检测算法，会引入更加糟糕的复杂度。

### 键（Keys）

为了解决这个看起来很棘手的问题，引入了一个可选的属性。可以给每个子级一个键值，用于将来的匹配比较。如果指定了一个键值，React 就能够检测出节点插入、移除和替换，并且借助哈希表使节点移动复杂度为 O(n)。


```xml
renderA: <div><span key="first">first</span></div>
renderB: <div><span key="second">second</span><span key="first">first</span></div>
=> [insertNode <span>second</span>]
```

在实际开发中，生成一个键值不是很困难。大多数时候，要展示的元素已经有一个唯一的标识了。当没有唯一标识的时候，可以给组件模型添加一个新的 ID 属性，或者计算部分内容的哈希值来生成一个键值。记住，键值仅需要在兄弟节点中唯一，而不是全局唯一。


## 权衡（Trade-offs）

同步更新算法只是一种实现细节，记住这点很重要。React 能在每次操作中重新渲染整个应用，最终的结果将会是一样的。我们定期优化这个启发式算法来使常规的应用场景更加快速。

在当前的实现中，能够检测到某个子级树已经从它的兄弟节点中移除，但是不能指出它是否已经移到了其它某个地方。当前算法将会重新渲染整个子树。

由于依赖于两个预判条件，如果这两个条件都没有满足，性能将会大打折扣。

1、算法将不会尝试匹配不同组件类的子树。如果发现正在使用的两个组件类输出的 DOM 结构非常相似，你或许想把这两个组件类改成一个组件类。实际上， 这不是个问题。

2、如果没有提供稳定的键值（例如通过 Math.random() 生成），所有子树将会在每次数据更新中重新渲染。通过给开发者设置键值的机会，能够给特定场景写出更优化的代码。

