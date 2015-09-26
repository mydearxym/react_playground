---
layout: page
title: 用于构建用户界面的JAVASCRIPT库
id: home
---

<section class="light home-section">
  <div class="marketing-row">
    <div class="marketing-col">
      <h3>仅仅是UI</h3>
      <p>
        许多人使用React作为MVC架构的V层。
        尽管React并没有假设过你的其余技术栈，
        但它仍可以作为一个小特征轻易地在已有项目中使用
      </p>
    </div>
    <div class="marketing-col">
      <h3>虚拟DOM</h3>
      <p>
        React为了更高超的性能而使用虚拟DOM作为其不同的实现。
        它同时也可以由服务端Node.js渲染 － 而不需要过重的浏览器DOM支持
      </p>
    </div>
    <div class="marketing-col">
      <h3>数据流</h3>
      <p>
        React实现了单向响应的数据流，从而减少了重复代码，这也是它为什么比传统数据绑定更简单。
      </p>
    </div>
  </div>
</section>
<hr class="home-divider" />
<section class="home-section">
  <div id="examples">
    <div class="example">
      <h3>一个简单的组件</h3>
      <p>
        React组件通过一个 <code>render()</code> 方法，接受输入的参数并返回展示的对象。 <br/>
        以下这个例子使用了JSX，它类似于XML的语法<br/>
        输入的参数通过 <code>render()</code> 传入组件后，将存储在<code>this.props</code>
      </p>
      <p>
        <strong>JSX是可选的，并不强制要求使用。</strong><br/>
        点击 &quot;Compiled JS&quot; 可以看到JSX编译之后的JavaScript代码
      </p>
      <div id="helloExample"></div>
    </div>
    <div class="example">
      <h3>一个有状态的组件</h3>
      <p>
        除了接受输入数据（通过 <code>this.props</code> ），组件还可以保持内部状态数据（通过 <code>this.state</code> ）。当一个组件的状态数据的变化，展现的标记将被重新调用 <code>render()</code> 更新。
      </p>
      <div id="timerExample"></div>
    </div>
    <div class="example">
       <h3>一个应用程序</h3>
       <p>
          通过使用 <code>props</code> 和 <code>state</code>, 我们可以组合构建一个小型的Todo程序。<br/>
          下面例子使用 <code>state</code> 去监测当前列表的项以及用户已经输入的文本。
          尽管事件绑定似乎是以内联的方式，但他们将被收集起来并以事件代理的方式实现。
        </p>
        <div id="todoExample"></div>
    </div>
    <div class="example">
      <h3>一个使用外部插件的组件</h3>
      <p>
        React是灵活的，并且提供方法允许你跟其他库和框架对接。<br/>
        下面例子展现了一个案例，使用外部库Markdown实时转化textarea的值。
      </p>
      <div id="markdownExample"></div>
    </div>
  </div>
  <script type="text/javascript" src="js/examples/hello.js"></script>
  <script type="text/javascript" src="js/examples/timer.js"></script>
  <script type="text/javascript" src="js/examples/todo.js"></script>
  <script type="text/javascript" src="js/examples/markdown.js"></script>
</section>
<hr class="home-divider" />
<section class="home-bottom-section">
  <div class="buttons-unit">
    <a href="docs/getting-started.html" class="button">快速入门</a>
    <a href="downloads.html" class="button">下载 v{{site.react_version}}</a>
  </div>
</section>
