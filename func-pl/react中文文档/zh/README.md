# React文档和网站

我们使用[Jekyll](http://jekyllrb.com/)来构建这个网站，该网站（[绝大部分](http://zpao.com/posts/adding-line-highlights-to-markdown-code-fences/)）使用Markdown。

## 安装

如果你要在此网站上做修改，你将会想安装运行一个本地版本。

### 依赖

为了使用Jekyll，你需要先安装Ruby。

 - [Ruby](http://www.ruby-lang.org/) (version >= 1.8.7)
 - [RubyGems](http://rubygems.org/) (version >= 1.3.7)
 - [Bundler](http://gembundler.com/)

Mac OS X预装了Ruby，但是你可能需要更新RubyGems（通过`gem update --system`命令）。另外，[RVM](https://rvm.io/)和[rbenv](https://github.com/sstephenson/rbenv)也是安装Ruby的流行方式。

> 注意:
>
> 由于Rubygems官方网站有时候有问题，也许你需要使用[国内镜像](http://www.oschina.net/news/24321/rubygems-taobao-mirror)安装

一旦你拥有了RubyGems，并且安装了Bundler(通过`gem install bundler`命令)。

可以学习[Jekyll](http://jekyllrb.com/) 或 以下命令来完成Jekyll的安装

```sh
$ gem install jekyll
```

### 启动

使用Jekyll来启动本地网站（默认地址是`http://localhost:4000`）：

```sh
$ bundle exec rake
$ bundle exec jekyll serve -w
$ open http://localhost:4000/react/
```
# 文档目录

## 快速入门

* [快速开始](/zh/docs/getting-started.md)
* [教程](/zh/docs/tutorial.md)
* [深入理解React](/zh/docs/thinking-in-react.md)

## 指南

* [为什么使用React](/zh/docs/01-why-react.md)
* [数据呈现](/zh/docs/02-displaying-data.md)
    - [深入理解JSX](/zh/docs/02.1-jsx-in-depth.md)
    - [JSX的延展属性](/zh/docs/02.2-jsx-spread.md)
    - [JSX陷阱](/zh/docs/02.3-jsx-gotchas.md)
* [富交互性的动态用户界面](/zh/docs/03-interactivity-and-dynamic-uis.md)
* [复合组件](/zh/docs/04-multiple-components.md)
* [可复用组件](/zh/docs/05-reusable-components.md)
* [传递Props](/zh/docs/06-transferring-props.md)
* [表单组件](/zh/docs/07-forms.md)
* [浏览器中的工作原理](/zh/docs/08-working-with-the-browser.md)
    - [关于Refs的更多内容](/zh/docs/08.1-more-about-refs.md)
* [工具集成](/zh/docs/09-tooling-integration.md)
* [插件](/zh/docs/10-addons.md)
    - [动画](/zh/docs/10.1-animation.md)
    - [双向绑定](/zh/docs/10.2-form-input-binding-sugar.md)
    - [类名操作](/zh/docs/10.3-class-name-manipulation.md)
    - [测试工具集](/zh/docs/10.4-test-utils.md)
    - [克隆组件](/zh/docs/10.5-clone-with-props.md)
    - [Immutability Helpers](/zh/docs/10.6-update.md)
    - [PureRenderMixin](/zh/docs/10.7-pure-render-mixin.md)
    - [性能分析工具](/zh/docs/10.8-perf.md)

## 参考

* [顶层 API](/zh/docs/ref-01-top-level-api.md)
* [组件 API](/zh/docs/ref-02-component-api.md)
* [组件的详细说明和生命周期](/zh/docs/ref-03-component-specs.md)
* [标签和属性支持](/zh/docs/ref-04-tags-and-attributes.md)
* [事件系统](/zh/docs/ref-05-events.md)
* [与 DOM 的差异](/zh/docs/ref-06-dom-differences.md)
* [特殊的非 DOM 属性](/zh/docs/ref-07-special-non-dom-attributes.md)
* [Reconciliation](/zh/docs/ref-08-reconciliation.md)
* [React （虚拟）DOM 术语](/zh/docs/ref-09-glossary.md)

## Flux

* [Flux](/zh/docs/flux-overview.md)

## Blog

* [React v0.13.1](/zh/_posts/2015-03-16-react-v0.13.1.md)
* [React v0.13](/zh/_posts/2015-03-10-react-v0.13.md)

# 翻译规范

[中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)

