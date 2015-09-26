---
id: events
title: 事件系统
permalink: events.html
prev: tags-and-attributes.html
next: dom-differences.html
---

## 虚拟事件对象

事件处理器将会传入`虚拟事件对象`的实例，一个对浏览器本地事件的跨浏览器封装。它有和浏览器本地事件相同的属性和方法，包括 `stopPropagation()` 和 `preventDefault()`，但是没有浏览器兼容问题。

如果因为一些因素，需要底层的浏览器事件对象，只要使用 `nativeEvent` 属性就可以获取到它了。每一个`虚拟事件对象`都有下列的属性：

```javascript
boolean bubbles
boolean cancelable
DOMEventTarget currentTarget
boolean defaultPrevented
number eventPhase
boolean isTrusted
DOMEvent nativeEvent
void preventDefault()
void stopPropagation()
DOMEventTarget target
number timeStamp
string type
```

> 注意：
>
> 对于 v0.12，在事件处理函数中返回 `false` 将不会阻止事件冒泡。取而代之的是在合适的应用场景下，手动调用 `e.stopPropagation()` 或者 `e.preventDefault()`。


## 支持的事件

React 标准化了事件对象，因此在不同的浏览器中都会有相同的属性。

如下的事件处理器在事件冒泡阶段触发。要在捕获阶段触发某个事件处理器，在事件名字后面追加 `Capture` 字符串；例如，使用 `onClickCapture` 而不是 `onClick` 来在捕获阶段处理点击事件。


### 剪贴板事件

事件名：

```
onCopy onCut onPaste
```

属性：

```javascript
DOMDataTransfer clipboardData
```


### 键盘事件：

事件名：

```
onKeyDown onKeyPress onKeyUp
```

属性：

```javascript
boolean altKey
Number charCode
boolean ctrlKey
function getModifierState(key)
String key
Number keyCode
String locale
Number location
boolean metaKey
boolean repeat
boolean shiftKey
Number which
```


### 焦点事件

事件名：

```
onFocus onBlur
```

属性：

```javascript
DOMEventTarget relatedTarget
```


### 表单事件

事件名：

```
onChange onInput onSubmit
```

更多关于 onChange 事件的信息，参考[表单](/react/docs/forms.html)。


### 鼠标事件

事件名：

```
onClick onDoubleClick onDrag onDragEnd onDragEnter onDragExit onDragLeave
onDragOver onDragStart onDrop onMouseDown onMouseEnter onMouseLeave
onMouseMove onMouseOut onMouseOver onMouseUp
```

属性：

```javascript
boolean altKey
Number button
Number buttons
Number clientX
Number clientY
boolean ctrlKey
function getModifierState(key)
boolean metaKey
Number pageX
Number pageY
DOMEventTarget relatedTarget
Number screenX
Number screenY
boolean shiftKey
```


### 触摸事件

为了使触摸事件生效，在渲染所有组件之前调用 `React.initializeTouchEvents(true)`。

事件名：

```
onTouchCancel onTouchEnd onTouchMove onTouchStart
```

属性：

```javascript
boolean altKey
DOMTouchList changedTouches
boolean ctrlKey
function getModifierState(key)
boolean metaKey
boolean shiftKey
DOMTouchList targetTouches
DOMTouchList touches
```


### UI 事件

事件名：

```
onScroll
```

属性：

```javascript
Number detail
DOMAbstractView view
```


### 鼠标滚轮滚动事件

事件名：

```
onWheel
```

属性：

```javascript
Number deltaMode
Number deltaX
Number deltaY
Number deltaZ
```
