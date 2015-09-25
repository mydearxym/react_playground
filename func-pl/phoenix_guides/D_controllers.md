Phoenix controllers act as intermediary modules. Their functions - called actions - are invoked from the router in response to HTTP requests. The actions, in turn, gather all the necessary data and perform all the necessary steps before invoking the view layer to render a template or returning a JSON response.

Phoenix controllers also build on the Plug package, and are themselves plugs. Controllers provide the functions to do almost anything we need to in an action. If we do find ourselves looking for something that Phoenix controllers don't provide, however, we might find what we're looking for in Plug itself. Please see the [Plug Guide](http://www.phoenixframework.org/docs/understanding-plug) or [Plug Documentation](http://hexdocs.pm/plug/) for more information.

A newly generated Phoenix app will have a single controller, the `PageController`, which can be found at `web/controllers/page_controller.ex` and looks like this.

```elixir
defmodule HelloPhoenix.PageController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
```

The first line below the module definition invokes the `__using__/1` macro of the `HelloPhoenix.Web` module, which imports some useful modules.

The `PageController` gives us the `index` action to display the Phoenix welcome page associated with the default route Phoenix defines in the router.

### Actions
Controller actions are just functions. We can name them anything we like as long as they follow Elixir's naming rules. The only requirement we must fulfill is that the action name matches a route defined in the router.

For example, in `web/router.ex` we could change the action name in the default route that Phoenix gives us in a new app from index:

```elixir
get "/", HelloPhoenix.PageController, :index
```

To test:

```elixir
get "/", HelloPhoenix.PageController, :test
```

As long as we change the action name in the `PageController` to `test` as well, the welcome page will load as before.

```elixir
defmodule HelloPhoenix.PageController do
  . . .

  def test(conn, _params) do
    render conn, "index.html"
  end
end
```

While we can name our actions whatever we like, there are conventions for action names which we should follow whenever possible. We went over these in the [Routing Guide](http://www.phoenixframework.org/docs/routing), but we'll take another quick look here.

- index   - renders a list of all items of the given resource type
- show    - renders an individual item by id
- new     - renders a form for creating a new item
- create  - receives params for one new item and saves it in a datastore
- edit    - retrieves an individual item by id and displays it in a form for editing
- update  - receives params for one edited item and saves it to a datastore
- delete  - receives an id for an item to be deleted and deletes it from a datastore

Each of these actions takes two parameters, which will be provided by Phoenix behind the scenes.

The first parameter is always `conn`, a struct which holds information about the request such as the host, path elements, port, query string, and much more. `conn`, comes to Phoenix via Elixir's Plug middleware framework. More detailed info about `conn` can be found in [plug's documentation](http://hexdocs.pm/plug/Plug.Conn.html).

The second parameter is `params`. Not surprisingly, this is a map which holds any parameters passed along in the HTTP request. It is a good practice to pattern match against params in the function signature to provide data in a simple package we can pass on to rendering. We saw this in the [Adding Pages guide](http://www.phoenixframework.org/docs/adding-pages) when we added a messenger parameter to our `show` route in `web/controllers/hello_controller.ex`.

```elixir
defmodule HelloPhoenix.HelloController do
  . . .

  def show(conn, %{"messenger" => messenger}) do
    render conn, "show.html", messenger: messenger
  end
end
```

In some cases - often in `index` actions, for instance - we don't care about parameters because our behavior doesn't depend on them. In those cases, we don't use the incoming params, and simply prepend the variable name with an underscore, `_params`. This will keep the compiler from complaining about the unused variable while still keeping the correct arity.

### Gathering Data

While Phoenix does not ship with its own data access layer, the Elixir project [Ecto](http://hexdocs.pm/ecto) provides a very nice solution for those using the [Postgres](http://www.postgresql.org/) relational database. (There are plans to offer other adapters for Ecto in the future.) We cover how to use Ecto in a Phoenix project in the [Ecto Models Guide](http://www.phoenixframework.org/docs/ecto-models).

Of course, there are many other data access options. [Ets](http://www.erlang.org/doc/man/ets.html) and [Dets](http://www.erlang.org/doc/man/ets.html) are key value data stores built into [OTP](http://www.erlang.org/doc/). OTP also provides a relational database called [mnesia](http://www.erlang.org/doc/man/mnesia.html) with its own query language called QLC. Both Elixir and Erlang also have a number of libraries for working with a wide range of popular data stores.

The data world is your oyster, but we won't be covering these options in these guides.

### Flash Messages

There are times when we need to communicate with users during the course of an action. Maybe there was an error updating a model. Maybe we just want to welcome them back to the application. For this, we have flash messages.

The `Phoenix.Controller` module provides the `put_flash/3` and `get_flash/2` functions to help us set and retrieve flash messages as a key value pair. Let's set two flash messages in our `HelloPhoenix.PageController` to try this out.

To do this we modify the `index` action as follows:

```elixir
defmodule HelloPhoenix.PageController do
  . . .
  def index(conn, _params) do
    conn
    |> put_flash(:info, "Welcome to Phoenix, from flash info!")
    |> put_flash(:error, "Let's pretend we have an error.")
    |> render("index.html")
  end
end
```

The `Phoenix.Controller` module is not particular about the keys we use. As long as we are internally consistent, all will be well. `:info` and `:error`, however, are common.

In order to see our flash messages, we need to be able to retrieve them and display them in a template/layout. One way to do the first part is with `get_flash/2` which takes `conn` and the key we care about. It then returns the value for that key.

Fortunately, our application layout, `web/templates/layout/app.html.eex`, already has markup for displaying flash messages.

```html
<p class="alert alert-info" role="alert"><%= get_flash(@conn, :info) %></p>
<p class="alert alert-danger" role="alert"><%= get_flash(@conn, :error) %></p>
```

When we reload the [Welcome Page](http://localhost:4000/), our messages should appear just above "Welcome to Phoenix!"

Besides `put_flash/3` and `get_flash/2`, the `Phoenix.Controller` module has another useful function worth knowing about. `clear_flash/1` takes only `conn` and removes any flash messages which might be stored in the session.

### Rendering

Controllers have several ways of rendering content. The simplest is to render some plain text using the `text/2` function which Phoenix provides.

Let's say we have a `show` action which receives an id from the params map, and all we want to do is return some text with the id. For that, we could do the following.

```elixir
def show(conn, %{"id" => id}) do
  text conn, "Showing id #{id}"
end
```
Assuming we had a route for `get "/our_path/:id"` mapped to this `show` action, going to `/our_path/15` in your browser should display `Showing id 15` as plain text without any HTML.

A step beyond this is rendering pure JSON with the `json/2` function. We need to pass it something that the [Poison library](https://github.com/devinus/poison) can parse into JSON, such as a map. (Poison is one of Phoenix's dependencies.)

```elixir
def show(conn, %{"id" => id}) do
  json conn, %{id: id}
end
```
If we again visit `our_path/15` in the browser, we should see a block of JSON with the key `id` mapped to the number `15`.

```elixir
{
  id: "15"
}
```
Phoenix controllers can also render HTML without a template. As you may have already guessed, the `html/2` function does just that. This time, we implement the `show` action like this.

```elixir
def show(conn, %{"id" => id}) do
  html conn, """
     <html>
       <head>
          <title>Passing an Id</title>
       </head>
       <body>
         <p>You sent in id #{id}</p>
       </body>
     </html>
    """
end
```

Hitting `/our_path/15` now renders the HTML string we defined in the `show` action, with the value `15` interpolated. Note that what we wrote in the action is not an `eex` template. It's a multi-line string, so we interpolate the `id` variable like this `#{id}` instead of this `<%= id %>`.

It is worth noting that the `text/2`, `json/2`, and `html/2` functions require neither a Phoenix view, nor a template to render.

The `json/2` function is obviously useful for writing APIs, and the other two may come in handy, but rendering a template into a layout with values we pass in is a very common case.

For this, Phoenix provides the `render/3` function.

Interestingly, `render/3` is defined in the `Phoenix.View` module instead of `Phoenix.Controller`, but it is aliased in `Phoenix.Controller` for convenience.

We have already seen the render function in the [Adding Pages Guide](http://www.phoenixframework.org/docs/adding-pages). Our `show` action in `web/controllers/hello_controller.ex` looked like this.

```elixir
defmodule HelloPhoenix.HelloController do
  use HelloPhoenix.Web, :controller

  def show(conn, %{"messenger" => messenger}) do
    render conn, "show.html", messenger: messenger
  end
end
```

In order for the `render/3` function to work correctly, the controller must have the same root name as the individual view. The individual view must also have the same root name as the template directory where the `show.html.eex` template lives. In other words, the `HelloController` requires `HelloView`, and `HelloView` requires the existence of the `web/templates/hello` directory, which must contain the `show.html.eex` template.

`render/3` will also pass the value which the `show` action received for `messenger` from the params hash into the template for interpolation.

If we need to pass values into the template when using `render`, that's easy. We can pass a dictionary like we've seen with `messenger: messenger`, or we can use `Plug.Conn.assign/3`, which conveniently returns `conn`.

```elixir
def index(conn, _params) do
  conn
  |> assign(:message, "Welcome Back!")
  |> render("index.html")
end
```
Note: The `Phoenix.Controller` module imports `Plug.Conn`, so shortening the call to `assign/3` works just fine.

We can access this message in our `index.html.eex` template, or in our layout, with this `<%= @message %>`.

Passing more than one value in to our template is as simple as connecting `assign/3` functions together in a pipeline.

```elixir
def index(conn, _params) do
  conn
  |> assign(:message, "Welcome Back!")
  |> assign(:name, "Dweezil")
  |> render("index.html")
end
```
With this, both `@message` and `@name` will be available in the `index.html.eex` template.

What if we want to have a default welcome message that some actions can override? That's easy, we just use `plug` and transform `conn` on its way towards the controller action.

```elixir
plug :assign_welcome_message, "Welcome Back"

def index(conn, _params) do
  conn
  |> assign(:name, "Dweezil")
  |> render("index.html")
end

defp assign_welcome_message(conn, msg) do
  assign(conn, :message, msg)
end
```

What if we want to plug `assign_welcome_message`, but only for some of our actions? Phoenix offers a solution to this by letting us specify which actions a plug should be applied to. If we only wanted `plug :assign_welcome_message` to work on the `index` and `show` actions, we could do this.

```elixir
defmodule HelloPhoenix.PageController do
  use HelloPhoenix.Web, :controller

  plug :assign_welcome_message, "Hi!" when action in [:index, :show]
. . .
```

### Sending responses directly

If none of the rendering options above quite fits our needs, we can compose our own using some of the functions that Plug gives us. Let's say we want to send a response with a status of "201" and no body whatsoever. We can easily do that with the `send_resp/3` function.

```elixir
def index(conn, _params) do
  conn
  |> send_resp(201, "")
end
```

Reloading [http://localhost:4000](http://localhost:4000) should show us a completely blank page. The network tab of our browser's developer tools should show a response status of "201".

If we would like to be really specific about the content type, we can use `put_resp_content_type/2` in conjunction with `send_resp/3`.

```elixir
def index(conn, _params) do
  conn
  |> put_resp_content_type("text/plain")
  |> send_resp(201, "")
end
```

Using Plug functions in this way, we can craft just the response we need.

Rendering does not end with the template, though. By default, the results of the template render will be inserted into a layout, which will also be rendered.

[Templates and layouts](http://www.phoenixframework.org/docs/templates) have their own guide, so we won't spend much time on them here. What we will look at is how to assign a different layout, or none at all, from inside a controller action.

### Assigning Layouts

Layouts are just a special subset of templates. They live in `/web/templates/layout`. Phoenix created one for us when we generated our app. It's called `app.html.eex`, and it is the layout into which all templates will be rendered by default.

Since layouts are really just templates, they need a view to render them. This is the `LayoutView` module defined in `/web/views/layout_view.ex`. Since Phoenix generated this view for us, we won't have to create a new one as long as we put the layouts we want to render inside the `/web/templates/layout` directory.

Before we create a new layout, though, let's do the simplest possible thing and render a template with no layout at all.

The `Phoenix.Controller` module provides the `put_layout/2` function for us to switch layouts. This takes `conn` as its first argument and a string for the basename of the layout we want to render. Another clause of the function will match on the boolean `false` for the second argument, and that's how we will render the Phoenix welcome page without a layout.

In a freshly generated Phoenix app, edit the `index` action of the `PageController` module `web/controllers/page_controller.ex` to look like this.

```elixir
def index(conn, params) do
  conn
  |> put_layout(false)
  |> render "index.html"
end
```
After reloading [http://localhost:4000/](http://localhost:4000/), we should see a very different page, one with no title, logo image, or css styling at all.

Very Important! For function calls in the middle of a pipeline, like `put_layout/2` here, it is critical to use parenthesis around the arguments because the pipe operator binds very tightly. This leads to parsing problems and very strange results.

If you ever get a stack trace that looks like this,

```text
**(FunctionClauseError) no function clause matching in Plug.Conn.get_resp_header/2

Stacktrace

    (plug) lib/plug/conn.ex:353: Plug.Conn.get_resp_header(false, "content-type")
```

where your argument replaces `conn` as the first argument, one of the first things to check is whether there are parentheses in the right places.

This is fine.

```elixir
def index(conn, params) do
  conn
  |> put_layout(false)
  |> render "index.html"
end
```

Whereas this won't work.

```elixir
def index(conn, params) do
  conn
  |> put_layout false
  |> render "index.html"
end
```

Now let's actually create another layout and render the index template into it. As an example, let's say we had a different layout for the admin section of our application which didn't have the logo image. To do this, let's copy the existing `app.html.eex` to a new file `admin.html.eex` in the same directory `web/templates/layout`. Then let's remove the line in `admin.html.eex` that displays the logo.

```html
<span class="logo"></span> <!-- remove this line -->
```

Then, pass the basename of the new layout into `put_layout/2` in our `index` action in `web/controllers/page_controller.ex`.

```elixir
def index(conn, params) do
  conn
  |> put_layout("admin.html")
  |> render "index.html"
end
```
When we load the page, and we should be rendering the admin layout without a logo.

### Overriding Rendering Formats

Rendering HTML through a template is fine, but what if we need to change the rendering format on the fly? Let's say that sometimes we need HTML, sometimes we need plain text, and sometimes we need JSON. Then what?

Phoenix allows us to change formats on the fly with the `_format` query string parameter. To make this happen, Phoenix requires an appropriately named view and an appropriately named template in the correct directory.

As an example, let's take the `PageController` index action from a newly generated app. Out of the box, this has the right view, `PageView`, the right templates directory, `/web/templates/page`, and the right template for rendering HTML, `index.html.eex`.

```elixir
def index(conn, _params) do
  render conn, "index.html"
end
```
What it doesn't have is an alternative template for rendering text. Let's add one at `/web/templates/page/index.text.eex`. Here is our example `index.text.eex` template.

```elixir
"OMG, this is actually some text."
```

There are just few more things we need to do to make this work. We need to tell our router that it should accept the `text` format. We do that by adding `text` to the list of accepted formats in the `:browser` pipeline. Let's open up `web/router.ex` and change the `plug :accepts` to include `text` as well as `html` like this.

```elixir
defmodule HelloPhoenix.Router do
  use HelloPhoenix.Web, :router

  pipeline :browser do
    plug :accepts, ["html", "text"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
. . .
```

We also need to tell the controller to render a template with the same format as the one returned by `Phoenix.Controller.get_format/1`. We do that by substituting the atom version of the template `:index` for the string version `"index.html"`.

```elixir
def index(conn, _params) do
  render conn, :index
end
```

If we go to [http://localhost:4000/?_format=text](http://localhost:4000/?_format=text), we will see `OMG, this is actually some text.`

Of course, we can pass data into our template as well. Let's change our action to take in a message parameter by removing the `_` in front of `params` in the function definition. This time, we'll use the somewhat less-flexible string version of our text template, just to see that it works as well.

```elixir
def index(conn, params) do
  render conn, "index.text", message: params["message"]
end
```

And let's add a bit to our text template.

```elixir
"OMG, this is actually some text." <%= @message %>
```

Now if we go to `http://localhost:4000/?_format=text&message=CrazyTown`, we will see "OMG, this is actually some text. CrazyTown"

### Setting the Content Type

Analogous to the `_format` query string param, we can render any sort of format we want by modifying the HTTP Accepts Header and providing the appropriate template.

If we wanted to render an xml version of our `index` action, we might implement the action like this in `web/page_controller.ex`.

```elixir
def index(conn, _params) do
  conn
  |> put_resp_content_type("text/xml")
  |> render "index.xml", content: some_xml_content
end
```

We would then need to provide an `index.xml.eex` template which created valid xml, and we would be done.

For a list of valid content mime-types, please see the [mime.types](https://github.com/elixir-lang/plug/blob/master/lib/plug/mime.types) documentation from the Plug middleware framework.

### Setting the HTTP Status

We can also set the HTTP status code of a response similarly to the way we set the content type. The `Plug.Conn` module, imported into all controllers, has a `put_status/2` function to do this.

`put_status/2` takes `conn` as the first parameter and as the second parameter either an integer or a "friendly name" used as an atom for the status code we want to set. Here is the list of supported [friendly names](https://github.com/elixir-lang/plug/blob/master/lib/plug/conn/status.ex#L7-L63).

Let's change the status in our `PageController` `index` action.

```elixir
def index(conn, _params) do
  conn
  |> put_status(202)
  |> render("index.html")
end
```

The status code we provide must be valid - [Cowboy](https://github.com/ninenines/cowboy), the web server Phoenix runs on, will throw an error on invalid codes. If we look at our development logs (which is to say, the iex session), or use our browser's web inspection network tool, we will see the status code being set as we reload the page.

If the action sends a response - either renders or redirects - changing the code will not change the behavior of the response. If, for example, we set the status to 404 or 500 and then `render "index.html"`, we do not get an error page. Similarly, no 300 level code will actually redirect. (It wouldn't know where to redirect to, even if the code did affect behavior.)

The following implementation of the `HelloPhoenix.PageController` `index` action, for example, will _not_ render the default `not_found` behavior as expected.

```elixir
def index(conn, _params) do
  conn
  |> put_status(:not_found)
  |> render("index.html")
end
```

The correct way to render the 404 page from `HelloPhoenix.PageController` is:

```elixir
def index(conn, _params) do
  conn
  |> put_status(:not_found)
  |> render(HelloPhoenix.ErrorView, "404.html")
end
```

### Redirection

Often, we need to redirect to a new url in the middle of a request. A successful `create` action, for instance, will usually redirect to the `show` action for the model we just created. Alternately, it could redirect to the `index` action to show all the things of that same type. There are plenty of other cases where redirection is useful as well.

Whatever the circumstance, Phoenix controllers provide the handy `redirect/2` function to make redirection easy. Phoenix differentiates between redirecting to a path within the application and redirecting to a url - either within our application or external to it.

In order to try out `redirect/2`, let's create a new route in `web/router.ex`.

```elixir
defmodule HelloPhoenix.Router do
  use HelloPhoenix.Web, :router
  . . .

  scope "/", HelloPhoenix do
    . . .
    get "/", PageController, :index
  end

  # New route for redirects
  scope "/", HelloPhoenix do
    get "/redirect_test", PageController, :redirect_test, as: :redirect_test
  end
  . . .
end
```

Then we'll change the `index` action to do nothing but redirect to our new route.

```elixir
def index(conn, _params) do
  redirect conn, to: "/redirect_test"
end
```

Finally, let's define in the same file the action we redirect to, which simply renders the text `Redirect!`.

```elixir
def redirect_test(conn, _params) do
  text conn, "Redirect!"
end
```

When we reload our [Welcome Page](http://localhost:4000), we see that we've been redirected to `/redirect_test` which has rendered the text `Redirect!`. It works!

If we care to, we can open up our developer tools, click on the network tab, and visit our root route again. We see two main requests for this page - a get to `/` with a status of `302`, and a get to `/redirect_test` with a status of `200`.

Notice that the redirect function takes `conn` as well as a string representing a relative path within our application. It can also take `conn` and a string representing a fully-qualified url.

```elixir
def index(conn, _params) do
  redirect conn, external: "http://elixir-lang.org/"
end
```

We can also make use of the path helpers we learned about in the [Routing Guide](http://www.phoenixframework.org/docs/routing). It's useful to `alias` the helpers in `web/router.ex` in order to shorten the expression.

```elixir
defmodule HelloPhoenix.PageController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    redirect conn, to: redirect_test_path(conn, :redirect_test)
  end
end
```

Note that we can't use the url helper here because `redirect/2` using the atom `:to`, expects a path. For example, the following will fail.

```elixir
def index(conn, _params) do
  redirect conn, to: redirect_test_url(conn, :redirect_test)
end
```

If we want to use the url helper to pass a full url to `redirect/2`, we must use the atom `:external`. Note that the url does not have to be truly external to our application to use `:external`, as we see in this example.

```elixir
def index(conn, _params) do
  redirect conn, external: redirect_test_url(conn, :redirect_test)
end
```
