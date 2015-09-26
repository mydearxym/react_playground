---
id: flux-overview
title: Flux Application Architecture
---

This page has been moved to the Flux website. [View it there](http://facebook.github.io/flux/docs/overview.html).

------------------------------------------------------------------------------

###Overview

>为了方便理解，主要的英文名词都没有翻译。比如：dispatcher（调度者）、 store（仓库）、view（视图）

Flux is the application architecture that Facebook uses for building client-side web applications. It complements React's composable view components by utilizing a unidirectional data flow. It's more of a pattern rather than a formal framework, and you can start using Flux immediately without a lot of new code.

Flux是Facebook用来构建用户端的web应用的应用程序体系架构。它通过利用数据的单向流动为React的可复用的视图组件提供了补充。相比于形式化的框架它更像是一个架构思想，不需要太多新的代码你就可以马上使用Flux构建你的应用。

Flux applications have three major parts: the dispatcher, the stores, and the views (React components). These should not be confused with Model-View-Controller. Controllers do exist in a Flux application, but they are controller-views — views often found at the top of the hierarchy that retrieve data from the stores and pass this data down to their children. Additionally, action creators — dispatcher helper methods — are used to support a semantic API that describes all changes that are possible in the application. It can be useful to think of them as a fourth part of the Flux update cycle.

Flux应用主要包括三部分：dispatcher、store和views（React components），千万不要和MVC(model-View-Controller)搞混。Controller在Flux应用中也确实存在，但是是以controller-view的形式。view通常处于应用的顶层，它从stores中获取数据，同时将这些数据传递给它的后代节点。另外，action creators - dispatcher辅助方法 - 一个被用来提供描述应用所有可能存在的改变的语义化的API。把它理解为Flux更新闭环的第四个组成部分可以帮助你更好的理解它。


Flux eschews MVC in favor of a unidirectional data flow. When a user interacts with a React view, the view propagates an action through a central dispatcher, to the various stores that hold the application's data and business logic, which updates all of the views that are affected. This works especially well with React's declarative programming style, which allows the store to send updates without specifying how to transition views between states.

Flux使用单向的数据流动来避开MVC. 当用户与React视图交互的时候，视图会通过中枢dispatcher产生一个action。然后大量的保存着应用数据和业务逻辑的视图接收到冒泡的action，更新所有受影响的view。这种方式很适合React这种声明式的编程方式，因为它的store更新，并不需要特别指定如何在view和state中过渡。

We originally set out to deal correctly with derived data: for example, we wanted to show an unread count for message threads while another view showed a list of threads, with the unread ones highlighted. This was difficult to handle with MVC — marking a single thread as read would update the thread model, and then also need to update the unread count model. These dependencies and cascading updates often occur in a large MVC application, leading to a tangled weave of data flow and unpredictable results.

我们独创性的解决了数据的获取：举个栗子，比如我们需要展示一个会话列表，高亮其中未读的会话，同时展示未读会话的数量。如果用MVC架构的话将很难处理这种情况，因为更新一个对话为已读的时候会更新对话model，然后同样也需要更新未读对话数量model（数量-1）。这样的依赖和瀑布式的更新在大型的应用中非常常见，导致错综复杂的数据流动和不可预测的结果。（这其实是Facebook之前的一个线上bug，有时候用户看到提示说有一条未读信息，但是点进去却发现没有）。


Control is inverted with stores: the stores accept updates and reconcile them as appropriate, rather than depending on something external to update its data in a consistent way. Nothing outside the store has any insight into how it manages the data for its domain, helping to keep a clear separation of concerns. Stores have no direct setter methods like setAsRead(), but instead have only a single way of getting new data into their self-contained world — the callback they register with the dispatcher.

反过来让 Store 来控制：store接受更新，并在合适的时机处理这些更新。而不是采用一贯依赖外部的方式来更新数据。在store外部，并没办法看到store内部是如何处理它内部的数据的，这样的方式保证了一个清晰的关注点分离。Store并没有类似setAsRead()这样直接的setter方法，但是在其自成一体的世界中拥有唯一个获取新数据的方法 - store通过dispatcher注册的回调函数。 

###Structure and Data Flow 

###Structure and Data Flow 

Data in a Flux application flows in a single direction:

在Flux应用中数据是单向流动的：
<figure>
  <img width="650" src="http://facebook.github.io/flux/img/flux-simple-f8-diagram-1300w.png" alt="unidirectional data flow in Flux">
</figure>

A unidirectional data flow is central to the Flux pattern, and the above diagram should be the primary mental model for the Flux programmer. The dispatcher, stores and views are independent nodes with distinct inputs and outputs. The actions are simple objects containing the new data and an identifying type property.

单向的数据流是Flux应用的核心特性，上图应该成为Flux程序员的主要心智模型。Dispatcher，stores和views是拥有清晰的输入输出的独立节点。而actions是包含了新的数据和身份属性的简单对象。

The views may cause a new action to be propagated through the system in response to user interactions:

用户的交互可能会使views产生新的action，这个action可以向整个系统中传播：

<figure>
  <img width="650" src="http://facebook.github.io/flux/img/flux-simple-f8-diagram-with-client-action-1300w.png" alt="unidirectional data flow in Flux">
</figure>

All data flows through the dispatcher as a central hub. Actions are provided to the dispatcher in an _action creator_ method, and most often originate from user interactions with the views. The dispatcher then invokes the callbacks that the stores have registered with it, dispatching actions to all stores. Within their registered callbacks, stores respond to whichever actions are relevant to the state they maintain. The stores then emit a _change_ event to alert the controller-views that a change to the data layer has occurred. Controller-views listen for these events and retrieve data from the stores in an event handler. The controller-views call their own `setState()` method, causing a re-rendering of themselves and all of their descendants in the component tree.

所有的数据的流动都通过中枢dispatcher。Action可以通过_action creator_产生并被提供给dispatcher，但多数情况下action是通过用户与views的交互产生。dispaer接收到action并执行那些已经注册的回调，向所有stores分发action。通过注册的回调，store响应那些与他们所保存的状态有关的action。然后store会触发一个 _change_ 事件，来提醒controller-views数据已经发生了改变。Controller-views监听这些事件并重新从store中获取数据。这些controller-views调用他们自己的`setState()`方法，重新渲染自身以及组件树上的所有后代组件。

<figure>
  <img width="650" src="http://facebook.github.io/flux/img/flux-simple-f8-diagram-explained-1300w.png" alt="unidirectional data flow in Flux">
</figure>


This structure allows us to reason easily about our application in a way that is reminiscent of functional reactive programming, or more specifically data-flow programming or flow-based programming, where data flows through the application in a single direction — there are no two-way bindings. Application state is maintained only in the stores, allowing the different parts of the application to remain highly decoupled. Where dependencies do occur between stores, they are kept in a strict hierarchy, with synchronous updates managed by the dispatcher.

这种的响应式编程，或者更准确的说数据流编程亦或基于数据流的编程，可以使我们很容易去推断我们的应用是如何工作的。因为我们的应用中数据是单项流动的，不存在双向绑定。应用的状态只保存在store中，这就允许应用中不同部分保持高度的低耦合。虽然依赖在store中也确实存在，但他们之间保持着严格的等级制度，并通过dispacher来管理同步更新。

We found that two-way data bindings led to cascading updates, where changing one object led to another object changing, which could also trigger more updates. As applications grew, these cascading updates made it very difficult to predict what would change as the result of one user interaction. When updates can only change data within a single round, the system as a whole becomes more predictable.

我们发现双向绑定会导致瀑布式的更新，一个对象发生变化会引起另一个对象的改变，并可能导致更多地更新。随着应用的增大，这些瀑布流式的更新方式会使我们很难预测用户交互可能会导致的改变。当更新只能以单一回合进行的时候，系统的可预测性也就会变得更高。

Let's look at the various parts of Flux up close. A good place to start is the dispatcher.

让我们来看看Flux的各个部分。从diapatcher先开始会比较好

### A Single Dispatcher 
### Dispatcher

The dispatcher is the central hub that manages all data flow in a Flux application. It is essentially a registry of callbacks into the stores and has no real intelligence of its own — it is a simple mechanism for distributing the actions to the stores. Each store registers itself and provides a callback. When an action creator provides the dispatcher with a new action, all stores in the application receive the action via the callbacks in the registry.

dispatcher 就像是一个中央的集线器，管理著所有的数据流。本质上它就是 store callback 的注册表，本身并没有实际的高度功能。它就是一个用来向stores分发actions的机器。 每一个 store 各自注册自己的 callback 以提供对应的处理动作。当 dispatcher 发出一个 action 时，应用中所有的store都会通过注册的callback收到这个action。

As an application grows, the dispatcher becomes more vital, as it can be used to manage dependencies between the stores by invoking the registered callbacks in a specific order. Stores can declaratively wait for other stores to finish updating, and then update themselves accordingly.

随着应用的增长，dispacher会变得更加必不可少，因为它能够指定注册的callback的执行顺序来管理store之间的依赖。store可以被声明等待其他store完成更新之后，再执行更新。

The same dispatcher that Facebook uses in production is available through npm, Bower, or GitHub.

Facebook目前在生产环境中使用的flux可以分别在npm, Bower，or Gihub中获取。

###Stores 

###Stores

Stores contain the application state and logic. Their role is somewhat similar to a model in a traditional MVC, but they manage the state of many objects — they do not represent a single record of data like ORM models do. Nor are they the same as Backbone's collections. More than simply managing a collection of ORM-style objects, stores manage the application state for a particular domain within the application.

Stores 包含了应用的状态和逻辑，它有点儿像传统MVC中的model层，但是却管理这多个对象的状态 - 他们不像传统的ORM model 只管理单个的数据记录，和backbone中得collection也不一样。

For example, Facebook's Lookback Video Editor utilized a TimeStore that kept track of the playback time position and the playback state. On the other hand, the same application's ImageStore kept track of a collection of images. The TodoStore in our TodoMVC example is similar in that it manages a collection of to-do items. A store exhibits characteristics of both a collection of models and a singleton model of a logical domain.

举个栗子，Facebook的回看视频编辑器使用TimeStore来保存播放时间和播放状态。另外，应用中的ImageStore保存着图片的集合。再比如说我们的TodoMVC示例中，TodoStore也类似地管理着to-do items的集合。store典型的特征就是既是models的集合，又是所属业务域下的model实例。

As mentioned above, a store registers itself with the dispatcher and provides it with a callback. This callback receives the action as a parameter. Within the store's registered callback, a switch statement based on the action's type is used to interpret the action and to provide the proper hooks into the store's internal methods. This allows an action to result in an update to the state of the store, via the dispatcher. After the stores are updated, they broadcast an event declaring that their state has changed, so the views may query the new state and update themselves.

就像上面所说的，store在dispacher中注册，并提供相应地回调。回调会接收action并把它当成自己的一个参数。当action被触发，回调函数会使用swich语句来解析action中的type参数，并在合适的type下提供钩子来执行内部方法。这就允许action通过dispacher来响应store中的state更新。store更新完成之后，会向应用中广播一个change事件，views可以选择响应事件来重新获取新的数据并更新。

###Views and Controller-Views 
###Views and Controller-Views 
React provides the kind of composable and freely re-renderable views we need for the view layer. Close to the top of the nested view hierarchy, a special kind of view listens for events that are broadcast by the stores that it depends on. We call this a controller-view, as it provides the glue code to get the data from the stores and to pass this data down the chain of its descendants. We might have one of these controller-views governing any significant section of the page.

React提供了一种可组合式的view让我们可以自由组合展示层。在接近顶层的地方，有些view需要监听所依赖的store的广播事件。我们称之为controller-view，因为他们提供了胶水代码来从store中获取数据，并向下层层传递这些数据。我们会利用这些controller-views来处理页面上某些重要部分。

When it receives the event from the store, it first requests the new data it needs via the stores' public getter methods. It then calls its own setState() or forceUpdate() methods, causing its render() method and the render() method of all its descendants to run.

当它接收到store的广播事件后，它首先会通过store的公共getter方法来获取所需的数据，然后调用自身的setState() 或 forceUpdate()方法来促使自身和后代的重新渲染。

We often pass the entire state of the store down the chain of views in a single object, allowing different descendants to use what they need. In addition to keeping the controller-like behavior at the top of the hierarchy, and thus keeping our descendant views as functionally pure as possible, passing down the entire state of the store in a single object also has the effect of reducing the number of props we need to manage.

在单一实例中，我们通常会向后代view传递全部数据，而让他们自己从中提取所需数据。此外我们在结构的顶部也维持着类似controller的行为，并且让后代的view保持的function特性。通过向后代传递所有的数据，也有助于减少我们需要管理的props的数量。

Occasionally we may need to add additional controller-views deeper in the hierarchy to keep components simple. This might help us to better encapsulate a section of the hierarchy related to a specific data domain. Be aware, however, that controller-views deeper in the hierarchy can violate the singular flow of data by introducing a new, potentially conflicting entry point for the data flow. In making the decision of whether to add a deep controller-view, balance the gain of simpler components against the complexity of multiple data updates flowing into the hierarchy at different points. These multiple data updates can lead to odd effects, with React's render method getting invoked repeatedly by updates from different controller-views, potentially increasing the difficulty of debugging.

偶尔，我们需要在系统的更深层的地方加入controller-views来保持我们的组件的简单。这有助于封装一个特定的数据域下的相关部分。需要注意的是，系统深层的controller-views可能会影响数据的单向流动，因为他们可能会引入一些新的，潜在的存在冲突的数据流入口。在决定是否增加深层的controller-views时，我们需要多方面权衡简单的组件和复杂多样的数据更新流这两点。这些多样的数据更新可能会导致一些古怪的副作用，伴随着不同的controller-views的render调用，潜在的增加了Debug的难度。

###Actions 
### Actions
The dispatcher exposes a method that allows us to trigger a dispatch to the stores, and to include a payload of data, which we call an action. The action's creation may be wrapped into a semantic helper method which sends the action to the dispatcher. For example, we may want to change the text of a to-do item in a to-do list application. We would create an action with a function signature like updateText(todoId, newText) in our TodoActions module. This method may be invoked from within our views' event handlers, so we can call it in response to a user interaction. This action creator method also adds a type to the action, so that when the action is interpreted in the store, it can respond appropriately. In our example, this type might be named something like TODO_UPDATE_TEXT.

dispatcher提供了一个可以允许我们向store中触发分发的方法，我们称之为action。它包含了一个数据的payload。action生成被包含进一个语义化的辅助方法中，来发送action到dispatcher。比如，我们想更新todo应用中一个todo-item的文本内容。我们会在TodoActions模块中生成一个类似updateText(todoId, newText) 这样的函数，这个函数可以被视图事件处理调用执行，因此我们可以通过调用它来响应用户交互。action生成函数同样会增加一个type参数，根据type的不同，store可以做出合适的响应。在我们的例子中，这个type可以叫做TODO_UPDATE_TEXT。

一个payload大概是这个样子的：
```
{  
  source: "SERVER_ACTION",  
  action: {  
    type: "RECEIVE_RAW_NODES",  
    addition: "some data",  
    rawNodes: rawNodes  
  }  
} 
```

Actions may also come from other places, such as the server. This happens, for example, during data initialization. It may also happen when the server returns an error code or when the server has updates to provide to the application.

Actions也可能来自其他地方，比如服务器端。这种情况可能会在数据初始化的时候出现，也可能是当服务器视图更新的时候返回了错误的时候出现。

###What About that Dispatcher? 
###What About that Dispatcher?

As mentioned earlier, the dispatcher is also able to manage dependencies between stores. This functionality is available through the waitFor() method within the Dispatcher class. We did not need to use this method within the extremely simple TodoMVC application, but it becomes vital in a larger, more complex application.

就像之前提到的那样，dispatcher也可以用来管理store之间的依赖。我们可以通过dispacher的waitFor()方法来实现。在类似TodoMVC这样简单地应用中我们可能用不到这个方法，但是在更大型，更复杂的应用的它会变得不可或缺。

Within the TodoStore's registered callback we could explicitly wait for any dependencies to first update before moving forward:

在执行TodoStore的注册回调时，我们可以明确地等待任何依赖先更新，然后再进行后续的处理：

```
case 'TODO_CREATE':
  Dispatcher.waitFor([
    PrependedTextStore.dispatchToken,
    YetAnotherStore.dispatchToken
  ]);

  TodoStore.create(PrependedTextStore.getText() + ' ' + action.text);
  break;
```

waitFor() accepts a single argument which is an array of dispatcher registry indexes, often called dispatch tokens. Thus the store that is invoking waitFor() can depend on the state of another store to inform how it should update its own state.

waitFor()的参数是一个包含了dispatcher注册索引的数组，这个索引通常被称之为dispatch tokens。因此store可以使用waitFor()来依赖其他的state，以此来确定如何更新它自己的state。

A dispatch token is returned by register() when registering callbacks for the Dispatcher:

使用register()方法注册回调的时候会返回一个id，这个id可以用作dispatch token

```
PrependedTextStore.dispatchToken = Dispatcher.register(function (payload) {
  // ...
});
```

For more on waitFor(), actions, action creators and the dispatcher, please see Flux: Actions and the Dispatcher.

想了解更多关于waitFor(), actions, action creators 以及 dispatcher相关的知识，请参看[Flux: Actions 和 Dispatcher](http://facebook.github.io/flux/docs/actions-and-the-dispatcher.html#content)


