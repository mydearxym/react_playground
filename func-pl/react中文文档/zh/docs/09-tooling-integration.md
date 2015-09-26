---
id: tooling-integration
title: 工具集成（Tooling Integration）
permalink: tooling-integration.html
prev: more-about-refs.html
next: addons.html
---

每个项目使用不同的系统来构建和部署JavaScript。我们尝试尽量让React环境无关。

## React

### CDN托管的React

我们在我们的[下载页面](/react/downloads.html)提供了React的CDN托管版本。这些预构建的文件使用UMD模块格式。直接简单地把它们放在`<script>`标签中将会给你环境的全局作用域引入一个`React`对象。React也可以在CommonJS和AMD环境下正常工作。


### 使用主分支

我们在[GitHub仓库](https://github.com/facebook/react)的主分支上有一些构建指令。我们在`build/modules`下构建了符合CommonJS模块规范的树形目录，你可以放置在任何环境或者使用任何打包工具，只要支持CommonJS规范。

## JSX

### 浏览器中的JSX转换

如果你喜欢使用JSX，我们[在我们的下载页面](/react/downloads.html)提供了一个用于开发的浏览器中的JSX转换器。简单地用一个`<script type="text/jsx">`标签来触发JSX转换器。

> 注意：
>
> 浏览器中的JSX转换器是相当大的，并且会在客户端导致无谓的计算，这些计算是可以避免的。不要在生产环境使用 - 参考下一节。


### 生产环境化：预编译JSX

如果你有[npm](http://npmjs.org/)，你可以简单地运行`npm install -g react-tools`来安装我们的命令行`jsx`工具。这个工具会把使用JSX语法的文件转换成纯的可以直接在浏览器里面运行起来的JavaScript文件。它也会为你监视目录，然后自动转换变化的文件；例如：`jsx --watch src/ build/`。运行`jsx --help`来查看更多关于如何使用这个工具的信息。


### 有用的开源项目

开源社区开发了在几款编辑器中集成JSX的插件和构建系统。点击[JSX集成](https://github.com/facebook/react/wiki/Complementary-Tools#jsx-integrations)查看所有内容。
