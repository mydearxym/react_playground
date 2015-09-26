---
id: tags-and-attributes
title: 标签和属性支持
permalink: tags-and-attributes.html
prev: component-specs.html
next: events.html
---

## 支持的标签

React 尝试支持所用常用的元素。如果你需要的元素没有在下面列出来，请提交一个问题（issue）。

### HTML 元素

下列的 HTML 元素是被支持的：

```
a abbr address area article aside audio b base bdi bdo big blockquote body br
button canvas caption cite code col colgroup data datalist dd del details dfn
dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
h6 head header hr html i iframe img input ins kbd keygen label legend li link
main map mark menu menuitem meta meter nav noscript object ol optgroup option
output p param picture pre progress q rp rt ruby s samp script section select
small source span strong style sub summary sup table tbody td textarea tfoot th
thead time title tr track u ul var video wbr
```

### SVG 元素

下列的 SVG 元素是被支持的：

```
circle defs ellipse g line linearGradient mask path pattern polygon polyline
radialGradient rect stop svg text tspan
```

你或许对 [react-art](https://github.com/facebook/react-art) 也感兴趣，它是一个为 React 写的渲染到 Canvas、SVG 或者 VML（IE8） 的绘图库。


## 支持的属性

React 支持所有 `data-*` 和 `aria-*` 属性，也支持下面列出的属性。

> 注意：
>
> 所有的属性都是驼峰命名的，`class` 属性和 `for` 属性分别改为 `className` 和 `htmlFor`，来符合 DOM API 规范。

对于支持的事件列表，参考[支持的事件](/react/docs/events.html)。

### HTML 属性

这些标准的属性是被支持的：

```
accept acceptCharset accessKey action allowFullScreen allowTransparency alt
async autoComplete autoPlay cellPadding cellSpacing charSet checked classID
className cols colSpan content contentEditable contextMenu controls coords
crossOrigin data dateTime defer dir disabled download draggable encType form
formAction formEncType formMethod formNoValidate formTarget frameBorder height
hidden href hrefLang htmlFor httpEquiv icon id label lang list loop manifest
marginHeight marginWidth max maxLength media mediaGroup method min multiple
muted name noValidate open pattern placeholder poster preload radioGroup
readOnly rel required role rows rowSpan sandbox scope scrolling seamless
selected shape size sizes span spellCheck src srcDoc srcSet start step style
tabIndex target title type useMap value width wmode
```

另外，下面非标准的属性也是被支持的：

- `autoCapitalize autoCorrect` 用于移动端的 Safari。
- `property` 用于 [Open Graph](http://ogp.me/) 原标签。
- `itemProp itemScope itemType` 用于 [HTML5 microdata](http://schema.org/docs/gs.html)。

也有 React 特有的属性 `dangerouslySetInnerHTML` （[更多信息](/react/docs/special-non-dom-attributes.html)），用于直接插入 HTML 字符串到组件中。

### SVG 属性

```
cx cy d dx dy fill fillOpacity fontFamily fontSize fx fy gradientTransform
gradientUnits markerEnd markerMid markerStart offset opacity
patternContentUnits patternUnits points preserveAspectRatio r rx ry
spreadMethod stopColor stopOpacity stroke strokeDasharray strokeLinecap
strokeOpacity strokeWidth textAnchor transform version viewBox x1 x2 x y1 y2 y
```
