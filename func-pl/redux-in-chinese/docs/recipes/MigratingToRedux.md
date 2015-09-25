# 迁移到 Redux

Redux 不是一个整体的框架，而是一系列的约定和[一些让他们协同工作的函数](../api/README.md)。你的 Redux 项目中的主要代码不会是使用 Redux 的 API，因为大多数时间你都会在编写功能。

这让到 Redux 的双向迁移都非常的容易。
我们并不想限制你！

## 迁移 Flux 项目

[Reducer](../Glossary.md#reducer) 抓住了 Flux Store 的本质，所以这让逐步迁移一个 Flux 项目到 Redux 上面来变成了可能，无论你使用了 [Flummox](http://github.com/acdlite/flummox)、[Alt](http://github.com/goatslacker/alt)、[traditional Flux](https://github.com/facebook/flux) 还是其他 Flux 库。

同样你也可以将 Redux 的项目通过相同的步骤迁移回上述的这些 Flux 框架。

你的迁移过程大致包含几个步骤：

* 创建一个叫做 `createFluxStore(reducer)` 的函数，通过 reducer 函数适配你当前项目的 Flux Store。从代码来看，这个函数很像 Redux 中 [`createStore`](../api/createStore.md) 的实现。它的 dispatch 处理器应该根据不同的 action 来调用不同的 `reducer`，保存新的 state 并抛出更新事件。

* 通过创建 `createFluxStore(reducer)` 的方法来将每个 Flux Store 逐步重写为 Reducer，这个过程中你的应用中其他部分代码感知不到任何变化，仍可以和原来一样使用 Flux Store 。

* 当重写你的 Store 时，你会发现你应该避免一些明显违反 Flux 模式的使用方法，例如在 Store 中请求 API、或者在 Store 中触发 action。一旦基于 reducer 来构建你的 Flux 代码，它会变得更易于理解。

* 当你所有的 Flux Store 全部基于 reducer 来实现时，你就可以利用 [`combineReducers(reducers)`](../api/combineReducers.md) 将多个 reducer 合并到一起，然后在应用里使用这个唯一的 Redux Store。

* 现在，剩下的就只是[使用 react-redux](../basics/UsageWithReact.md) 或者类似的库来处理你的UI部分。

* 最后，你可以使用一些 Redux 的特性，例如利用 middleware 来进一步简化异步的代码。


## 迁移 Backbone 项目

对不起，你需要重写你的 Model 层。
它们区别太大了！
