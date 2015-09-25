# 三大原则

Redux 可以被描述成三大基础原则：

### 单一数据源

**整个应用的 [state](../Glossary.md#state) 被储存在一棵对象树中，它只有一个单一的 [store](../Glossary.md#store) 。**

这让同构应用开发变得非常容易。来自服务端的 state 可以轻而易举地被序列化并融合到没有额外代码影响的客户端上。由于是单一的 state 树，调试也变得非常容易。你也可以把应用的 state 保存下来加快开发速度。此外，受益于单一的 state 树，以前难以实现的像“撤销/重做”这类的功能也变得轻而易举。

```js
console.log(store.getState());

{
  visibilityFilter: 'SHOW_ALL',
  todos: [{
    text: 'Consider using Redux',
    completed: true,
  }, {
    text: 'Keep all state in a single tree',
    completed: false
  }]
}
```

### State 是只读的

**惟一改变 state 的办法就是触发 [action](../Glossary.md#action)，action 是一个描述要发生什么的对象。**

这让视图和网络请求不能直接修改 state，相反只能表达出需要修改的意图。因为所有的修改都被集中化处理，且严格按照顺序一个接一个执行，因此没有模棱两可的情况需要提防。 Action 就是普通对象而已，因此它们可以被日志打印、序列化、储存、后期调试或测试时回放出来。

```js
store.dispatch({
  type: 'COMPLETE_TODO',
  index: 1
});

store.dispatch({
  type: 'SET_VISIBILITY_FILTER',
  filter: 'SHOW_COMPLETED'
});
```

### 纯函数的形式来执行修改

**为了描述 action 如何改变 state 树，你需要编写 [reducers](../Glossary.md#reducer)。**

Reducer 只是一些纯函数，它接收之前的 state 和 action，并返回新的 state。刚开始你可以只有一个 reducer，随着应用变大，你可以把它拆成多个小的 reducers，分别独立地操作 state 树的不同部分，因为 reducer 只是普通函数，你可以控制它们被调用的顺序，传入附加数据，甚至编写可复用的 reducer 来做一些通用任务，如分页器。

```js
function visibilityFilter(state = 'SHOW_ALL', action) {
  switch (action.type) {
  case 'SET_VISIBILITY_FILTER':
    return action.filter;
  default:
    return state;
  }
}

function todos(state = [], action) {
  switch (action.type) {
  case 'ADD_TODO':
    return [...state, {
      text: action.text,
      completed: false
    }];
  case 'COMPLETE_TODO':
    return [
      ...state.slice(0, action.index),
      Object.assign({}, state[action.index], {
        completed: true
      }),
      ...state.slice(action.index + 1)
    ]
  default:
    return state;
  }
}

import { combineReducers, createStore } from 'redux';
let reducer = combineReducers({ visibilityFilter, todos });
let store = createStore(reducer);
```

就是这样，现在你已经明白 Redux 是怎么回事了。
