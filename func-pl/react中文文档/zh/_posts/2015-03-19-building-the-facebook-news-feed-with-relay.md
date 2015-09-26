---
title: "用 Relay 构建 Facebook 的 New Feed 应用"
author: Joseph Savona
---

在一月份的 React.js Conf 上，我们展示了一个 Relay 的预览版，它是一个新的在 React 中创建数据驱动应用的框架。这篇文章将会描述创建一个 Relay 应用的过程。这篇文章假设读者已经熟悉 Relay 和 GraphQL 的一些概念，因此如果你还不熟悉的话，建议先阅读[我们的简述博客](http://facebook.github.io/react/blog/2015/02/20/introducing-relay-and-graphql.html)或者观看[会议直播](https://www.youtube.com/watch?v=9sc8Pyc51uU)。

我们为公开发布 GraphQL 和 Relay 而努力准备。与此同时，我们将会继续提供你期待的信息。

<br/>

## Relay 架构

下面的图片展示了在客户端和服务器端 Relay 架构的主要部分：

<img src="http://facebook.github.io/react/img/blog/relay-components/relay-architecture.png" alt="Relay 架构" width="650" />

主要部分如下：

- Relay components： 反应数据的 React 组件。
- Actions： 当用户操作的时候，相应的数据应该如何改变的描述。
- Relay Store： 一个客户端的完全被框架管理的数据存储器。
- Server： 一个带有 GraphQL 终端的 HTTP 服务器（一个用于读，一个用于写），用于响应 GraphQL 查询。

这篇文章将会集中在 **Relay 组件** 上，描述 UI 封装单元以及它们的数据依赖。这些组件构成了 Relay 应用的主要部分。

<br/>

## 一个 Relay 应用

To see how components work and can be composed, let's implement a basic version of the Facebook News Feed in Relay. Our application will have two components: a `<NewsFeed>` that renders a list of `<Story>` items. We'll introduce the plain React version of each component first and then convert it to a Relay component. The goal is something like the following:

<img src="/react/img/blog/relay-components/sample-newsfeed.png" alt="Sample News Feed" width="360" />

<br/>

## The `<Story>` Begins

The first step is a React `<Story>` component that accepts a `story` prop with the story's text and author information. Note that all examples uses ES6 syntax and elide presentation details to focus on the pattern of data access.

```javascript
// Story.react.js
class Story extends React.Component {
  render() {
    var story = this.props.story;
    return (
      <View>
        <Image uri={story.author.profile_picture.uri} />
        <Text>{story.author.name}</Text>
        <Text>{story.text}</Text>
      </View>
    );
  }
}

module.exports = Story;
```

<br/>

## What's the `<Story>`?

Relay automates the process of fetching data for components by wrapping existing React components in Relay containers (themselves React components):

```javascript
// Story.react.js
class Story extends React.Component { ... }

module.exports = Relay.createContainer(Story, {
  queries: {
    story: /* TODO */
  }
});
```

Before adding the GraphQL query, let's look at the component hierarchy this creates:

<img src="/react/img/blog/relay-components/relay-containers.png" width="397" alt="React Container Data Flow" />

Most props will be passed through from the container to the original component. However, Relay will return the query results for a prop whenever a query is defined. In this case we'll add a GraphQL query for `story`:

```javascript
// Story.react.js
class Story extends React.Component { ... }

module.exports = Relay.createContainer(Story, {
  queries: {
    story: graphql`
      Story {
        author {
          name,
          profile_picture {
            uri
          }
        },
        text
      }
    `
  }
});
```

Queries use ES6 template literals tagged with the `graphql` function. Similar to how JSX transpiles to plain JavaScript objects and function calls, these template literals transpile to plain objects that describe queries. Note that the query's structure closely matches the object structure that we expected in `<Story>`'s render function.

<br/>

## `<Story>`s on Demand

We can render a Relay component by providing Relay with the component (`<Story>`) and the ID of the data (a story ID). Given this information, Relay will first fetch the results of the query and then `render()` the component. The value of `props.story` will be a plain JavaScript object such as the following:

```javascript
{
  author: {
    name: "Greg",
    profile_picture: {
      uri: "https://…"
    }
  },
  text: "The first Relay blog post is up…"
}
```

Relay guarantees that all data required to render a component will be available before it is rendered. This means that `<Story>` does not need to handle a loading state; the `story` is *guaranteed* to be available before `render()` is called. We have found that this invariant simplifies our application code *and* improves the user experience. Of course, Relay also has options to delay the fetching of some parts of our queries.

The diagram below shows how Relay containers make data available to our React components:

<img src="/react/img/blog/relay-components/relay-containers-data-flow.png" width="650" alt="Relay Container Data Flow" />

<br/>

## `<NewsFeed>` Worthy

Now that the `<Story>` is over we can continue with the `<NewsFeed>` component. Again, we'll start with a React version:

```javascript
// NewsFeed.react.js
class NewsFeed extends React.Component {
  render() {
    var stories = this.props.viewer.stories; // `viewer` is the active user
    return (
      <View>
        {stories.map(story => <Story story={story} />)}
        <Button onClick={() => this.loadMore()}>Load More</Button>
      </View>
    );
  }

  loadMore() {
    // TODO: fetch more stories
  }
}

module.exports = NewsFeed;
```

<br/>

## All the News Fit to be Relayed

`<NewsFeed>` has two new requirements: it composes `<Story>` and requests more data at runtime.

Just as React views can be nested, Relay queries can compose queries from child components. Composition in GraphQL uses ES6 template literal substitution: `${Component.getQuery('prop')}`. Pagination can be accomplished with a query parameter, specified with `<param>` (as in `stories(first: <count>)`):

```javascript
// NewsFeed.react.js
class NewsFeed extends React.Component { ... }

module.exports = Relay.createContainer(NewsFeed, {
  queryParams: {
    count: 3                             /* default to 3 stories */
  },
  queries: {
    viewer: graphql`
      Viewer {
        stories(first: <count>) {        /* fetch viewer's stories */
          edges {                        /* traverse the graph */
            node {
              ${Story.getQuery('story')} /* compose child query */
            }
          }
        }
      }
    `
  }
});
```

Whenever `<NewsFeed>` is rendered, Relay will recursively expand all the composed queries and fetch them in a single trip to the server. In this case, the `text` and `author` data will be fetched for each of the 3 story nodes.

Query parameters are available to components as `props.queryParams` and can be modified with `props.setQueryParams(nextParams)`. We can use these to implement pagination:

```javascript
// NewsFeed.react.js
class NewsFeed extends React.Component {
  render() { ... }

  loadMore() {
    // read current params
    var count = this.props.queryParams.count;
    // update params
    this.props.setQueryParams({
      count: count + 5
    });
  }
}
```

Now when `loadMore()` is called, Relay will send a GraphQL request for the additional five stories. When these stories are fetched, the component will re-render with the new stories available in `props.viewer.stories` and the updated count reflected in `props.queryParams.count`.

<br/>

## In Conclusion

These two components form a solid core for our application. With the use of Relay containers and GraphQL queries, we've enabled the following benefits:

- Automatic and efficient pre-fetching of data for an entire view hierarchy in a single network request.
- Trivial pagination with automatic optimizations to fetch only the additional items.
- View composition and reusability, so that `<Story>` can be used on its own or within `<NewsFeed>`, without any changes to either component.
- Automatic subscriptions, so that components will re-render if their data changes. Unaffected components will not re-render unnecessarily.
- Exactly *zero* lines of imperative data fetching logic. Relay takes full advantage of React's declarative component model.

But Relay has many more tricks up its sleeve. For example, it's built from the start to handle reads and writes, allowing for features like optimistic client updates with transactional rollback. Relay can also defer fetching select parts of queries, and it uses a local data store to avoid fetching the same data twice. These are all powerful features that we hope to explore in future posts.
