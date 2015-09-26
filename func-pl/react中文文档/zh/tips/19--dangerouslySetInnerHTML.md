---
id: dangerously-set-inner-html
title: Dangerously Set innerHTML
layout: tips
permalink: dangerously-set-inner-html.html
prev: children-undefined.html
---

不合时宜的使用 `innerHTML` 可能会导致 [cross-site scripting (XSS)](http://en.wikipedia.org/wiki/Cross-site_scripting) 攻击。 净化用户的输入来显示的时候，经常会出现错误，不合适的净化也是[导致网页攻击](http://owasptop10.googlecode.com/files/OWASP%20Top%2010%20-%202013.pdf) 的原因之一。


我们的设计哲学是让确保安全应该是简单的，开发者在执行“不安全”的操作的时候应该清楚地知道他们自己的意图。 `dangerouslySetInnerHTML` 这个 prop 的命名是故意这么设计的，以此来警告，它的 prop 值（ 一个对象而不是字符串 ）应该被用来表明净化后的数据。


在彻底的理解安全问题后果并正确地净化数据之后，生成只包含唯一 key  `__html` 的对象，并且对象的值是净化后的数据。下面是一个使用 JSX 语法的栗子：

```js
function createMarkup() { return {__html: 'First &middot; Second'}; };
<div dangerouslySetInnerHTML={createMarkup()} />
```


这么做的意义在于，当你不是有意地使用 `<div dangerouslySetInnerHTML={getUsername()} />` 时候，它并不会被渲染，因为 `getUsername()` 返回的格式是 `字符串` 而不是一个 `{__html: ''}` 对象。`{__html:...}` 背后的目的是表明它会被当成 "type/taint" 类型处理。 这种包裹对象，可以通过方法调用返回净化后的数据，随后这种标记过的数据可以被传递给 `dangerouslySetInnerHTML`。 基于这种原因，我们不推荐写这种形式的代码：`<div dangerouslySetInnerHTML={{'{{'}}__html: getMarkup()}} />`.


这个功能主要被用来与 DOM 字符串操作类库一起使用，所以提供的 HTML 必须要格式清晰（例如：传递 XML 校验 ）


想查看更完整的例子， 那么退回到[front page](/)最后一个例子。
