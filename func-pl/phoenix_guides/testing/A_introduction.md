Testing has become integral to the software development process, and the ability to easily write meaningful tests is an indispensable feature for any modern web framework. Phoenix takes this seriously, providing support files to make all the major components of the framework easy to test. It also generates test modules with real-world examples alongside any generated modules to help get us going.

Elixir ships with a built-in testing framework called [ExUnit](http://elixir-lang.org/docs/stable/ex_unit/). ExUnit strives to be clear and explicit, keeping magic to a minimum. Phoenix uses ExUnit for all of its testing, and we will use it here as well.

ExUnit refers to a test module as a "test case", and we will do the same.

Let's see this in action.

> Note: Before we proceed, we'll need to have PostgreSQL installed and running on our system. We'll also need to configure our repo with the correct login credentials. [The section on ecto.create in the Mix Tasks guide](http://www.phoenixframework.org/docs/mix-tasks#section--ecto-create-) has more information on this, and the [Ecto Models Guide](http://www.phoenixframework.org/docs/ecto-models) dives into the details on how it all works.

In a freshly generated application, let's run `mix test` at the root of the project. (Please see the [Up and Running Guide](http://www.phoenixframework.org/docs/up-and-running) for instructions on generating a new application.)

```console
$ mix test
==> ranch (compile)

. . .

Generated hello_phoenix app

Finished in 0.2 seconds (0.2s on load, 0.00s on tests)
4 tests, 0 failures
```

We already have four tests!

In fact, we already have a directory structure completely set up for testing, including a test helper and support files.

> Note: We didn't need to create or migrate our test database because the test helper took care of all that for us.

```console
test
├── channels
├── controllers
│   └── page_controller_test.exs
├── models
├── support
│   ├── channel_case.ex
│   ├── conn_case.ex
│   └── model_case.ex
├── test_helper.exs
└── views
    ├── error_view_test.exs
    └── page_view_test.exs
```

The test cases we get for free include `test/controllers/page_controller_test.exs`,  `test/views/error_view_test.exs`, and `test/views/page_view_test.exs`. Nice.

We're going to look at test cases in detail throughout the testing guides, but let's take a quick look at these three, just to get our feet wet.

The first test case we'll look at is `test/controllers/page_controller_test.exs`.

```elixir
defmodule HelloPhoenix.PageControllerTest do
  use HelloPhoenix.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
```

There are a couple of interesting things happening here.

The "get/2" function gives us a connection struct set up as if it had been used for a get request to "/". This saves us a considerable amount of tedious setup.

The assertion actually tests three things - that we got an HTML response (by checking for a content-type of "text/html"), that our response code was 200, and that the body of our response matched the string "Welcome to Phoenix!"

The error view test case, `test/views/error_view_test.exs`, illustrates a few interesting things of its own.

```elixir
defmodule HelloPhoenix.ErrorViewTest do
  use HelloPhoenix.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(HelloPhoenix.ErrorView, "404.html", []) ==
           "Page not found"
  end

  test "render 500.html" do
    assert render_to_string(HelloPhoenix.ErrorView, "500.html", []) ==
           "Server internal error"
  end

  test "render any other" do
    assert render_to_string(HelloPhoenix.ErrorView, "505.html", []) ==
           "Server internal error"
  end
end
```

`HelloPhoenix.ErrorViewTest` sets `async: true` which means that each individual test will run in parallel, greatly speeding up the test run. This works because none of the tests access any resources which share state, such as a database. If we set `async: true` for a test case which does access a database, different test processes might modify the same data, corrupting the test results.

It also imports `Phoenix.View` in order to use the `render_to_string/3` function. With that, all the assertions can be simple string equality tests.

The page view case, `test/views/page_view_test.exs`, does not contain any tests by default, but it is here for us when we need to add functions to our `HelloPhoenix.PageView` module.

```elixir
defmodule HelloPhoenix.PageViewTest do
  use HelloPhoenix.ConnCase, async: true
end
```

Let's also take a look at the support and helper files Phoenix provides us.

The default test helper file, `test/test_helper.ex`, creates and migrates our test database for us. It also starts a transaction for each test to run in. This will "clean" the database by rolling back the transaction as each test completes.

The test helper can also hold any testing-specific configuration our application might need.

```elixir
ExUnit.start

# Create the database, run migrations, and start the test transaction.
Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(HelloPhoenix.Repo)
```

The files in `test/support` are there to help us get our modules into a testable state. They provide convenience functions for tasks like setting up a connection struct and finding errors on an Ecto changeset. We'll take a closer look at them in action throughout the rest of the testing guides.

### Running Tests

Now that we have an idea what our tests are doing, let's look at different ways to run them.

As we saw near the beginning of this guide, we can run our entire suite of tests with `mix test`.

```console
$ mix test
....

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
4 tests, 0 failures

Randomized with seed 540755
```

If we would like to run all the tests in a given directory, `test/controllers` for instance, we can pass the path to that directory to `mix test`.

```console
$ mix test test/controllers/
.

Finished in 0.2 seconds (0.1s on load, 0.04s on tests)
1 tests, 0 failures

Randomized with seed 652376
```

In order to run all the tests in a specific file, we can pass the path to that file into `mix test`.

```console
$ mix test test/views/error_view_test.exs
...

Finished in 0.2 seconds (0.2s on load, 0.00s on tests)
3 tests, 0 failures

Randomized with seed 220535
```

And we can run a single test in a file by appending a colon and a line number to the filename.

Let's say we only wanted to run the test for the way `HelloPhoenix.ErrorView` renders `500.html`. The test begins on line 12 of the file, so this is how we would do it.

```console
$ mix test test/views/error_view_test.exs:12
Including tags: [line: "12"]
Excluding tags: [:test]

.

Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
1 tests, 0 failures

Randomized with seed 288117
```

We chose to run this specifying the first line of the test, but actually, any line of that test will do. These line numbers would all work - `:13`, `:14`, or `:15`.

### Running Tests Using Tags

ExUnit allows us to tag our tests at the case level or on the individual test level. We can then choose to run only the tests with a specific tag, or we can exclude tests with that tag and run everything else.

Let's experiment with how this works.

First, we'll add a `@moduletag` to `test/views/error_view_test.exs`.

```elixir
defmodule HelloPhoenix.ErrorViewTest do
  use HelloPhoenix.ConnCase, async: true

  @moduletag :error_view_case

  . . .
```

If we use only an atom for our module tag, ExUnit assumes that it has a value of `true`. We could also specify a different value if we wanted.

```elixir
defmodule HelloPhoenix.ErrorViewTest do
  use HelloPhoenix.ConnCase, async: true

  @moduletag error_view_case: "some_interesting_value"

  . . .
```

For now, let's leave it as a simple atom `@moduletag :error_view_case`.

We can run only the tests from the error view case by passing `--only error_view_case` into `mix test`.

```console
$ mix test --only error_view_case
Including tags: [:error_view_case]
Excluding tags: [:test]

...

Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
3 tests, 0 failures

Randomized with seed 125659
```

> Note: ExUnit tells us exactly which tags it is including and excluding for each test run. If we look back to the previous section on running tests, we'll see that line numbers specified for individual tests are actually treated as tags.
```console
$ mix test test/views/error_view_test.exs:12
Including tags: [line: "12"]
```

Specifying a value of `true` for `error_view_case` yields the same results.

```console
$ mix test --only error_view_case:true
Including tags: [error_view_case: "true"]
Excluding tags: [:test]

...

Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
3 tests, 0 failures

Randomized with seed 833356
```

Specifying `false` as the value for `error_view_case`, however, will not run any tests because no tags in our system match `error_view_case: false`.

```console
$ mix test --only error_view_case:false
Including tags: [error_view_case: "false"]
Excluding tags: [:test]



Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
0 tests, 0 failures

Randomized with seed 622422
```

We can use the `--exclude` flag in a similar way. This will run all of the tests except those in the error view case.

```console
mix test --exclude error_view_case
Excluding tags: [:error_view_case]

.

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
1 tests, 0 failures

Randomized with seed 682868
```

Specifying values for a tag works the same way for `--exclude` as it does for `--only`.

We can tag individual tests as well as full test cases. Let's tag a few tests in the error view case to see how this works.

```elixir
defmodule HelloPhoenix.ErrorViewTest do
  use HelloPhoenix.ConnCase, async: true

  . . .

  @tag individual_test: "yup"
  test "renders 404.html" do
    assert render_to_string(HelloPhoenix.ErrorView, "404.html", []) ==
    "Page not found"
  end

  @tag individual_test: "nope"
  test "render 500.html" do
    assert render_to_string(HelloPhoenix.ErrorView, "500.html", []) ==
    "Server internal error"
  end

  . . .
end

```

If we would like to run only tests tagged as `individual_test`, regardless of their value, this will work.

```console
$ mix test --only individual_test
Including tags: [:individual_test]
Excluding tags: [:test]

..

Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
2 tests, 0 failures

Randomized with seed 813729
```

We can also specify a value and run only tests with that value.

```console
$ mix test --only individual_test:yup
Including tags: [individual_test: "yup"]
Excluding tags: [:test]

.

Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
1 tests, 0 failures

Randomized with seed 770938
```

Similarly, we can run all tests except for those tagged with a given value.

```console
mix test --exclude individual_test:nope
Excluding tags: [individual_test: "nope"]

...

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
3 tests, 0 failures

Randomized with seed 539324
```

Here's an interesting case, let's exclude all of the tests from the error view case except the ones tagged with `individual_test`.

```console
$ mix test --exclude error_view_case --include individual_test
Including tags: [:individual_test]
Excluding tags: [:error_view_case]

...

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
3 tests, 0 failures

Randomized with seed 41241
```

This runs the two tests tagged with `individual_test` as well as the one from `test/controllers/page_controller_test.exs`.

We can be more specific and exclude all the tests from the error view case except the one tagged with `individual_test` that has the value "yup".

```console
$ mix test --exclude error_view_case --include individual_test:yup
Including tags: [individual_test: "yup"]
Excluding tags: [:error_view_case]

..

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
2 tests, 0 failures

Randomized with seed 61472
```

Finally, we can configure ExUnit to exclude tags by default. Let's configure it to always exclude tests with the `error_view_case` tag.

```elixir
ExUnit.start

# Create the database, run migrations, and start the test transaction.
Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(HelloPhoenix.Repo)

ExUnit.configure(exclude: [error_view_case: true])
```

Now when we run `mix test`, it only runs one spec from our `page_controller_test.exs`.

```console
$ mix test
Excluding tags: [error_view_case: true]

.

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
1 tests, 0 failures

Randomized with seed 186055
```

We can override this behavior with the `--include` flag, telling `mix test` to include tests tagged with `error_view_case`.

```console
$ mix test --include error_view_case
Including tags: [:error_view_case]
Excluding tags: [error_view_case: true]

....

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
4 tests, 0 failures

Randomized with seed 748424
```

### Randomization

Running tests in random order is a good way to ensure that our tests are truly isolated. If we notice that we get sporadic failures for a given test, it may be because a previous test changes the state of the system in ways that aren't cleaned up afterward, thereby affecting the tests which follow. Those failures might only present themselves if the tests are run in a specific order.

ExUnit, will randomize the order tests run in by default, using an integer to seed the randomization. If we notice that a specific random seed triggers our intermittent failure, we can re-run the tests with that same seed to reliably recreate that test sequence in order to help us figure out what the problem is.

```console
$ mix test --seed 401472
....

Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
4 tests, 0 failures

Randomized with seed 401472
```

### Generating More Files

We've seen what Phoenix gives us with a newly generated app. Now let's see what happens when we generate a new HTML resource.

Let's borrow the resource we created in the [Mix Tasks Guide](http://www.phoenixframework.org/docs/ecto-models).

At the root of our new application, let's run the `mix phoenix.gen.html` task with the following options.

```console
$ mix phoenix.gen.html User users name:string email:string bio:string number_of_pets:integer

. . . (lots of compilation)

Generated hello_phoenix app
* creating priv/repo/migrations/20150519043351_create_user.exs
* creating web/models/user.ex
* creating test/models/user_test.exs
* creating web/controllers/user_controller.ex
* creating web/templates/user/edit.html.eex
* creating web/templates/user/form.html.eex
* creating web/templates/user/index.html.eex
* creating web/templates/user/new.html.eex
* creating web/templates/user/show.html.eex
* creating web/views/user_view.ex
* creating test/controllers/user_controller_test.exs

Add the resource to the proper scope in web/router.ex:

    resources "/users", UserController

and then update your repository by running migrations:

    $ mix ecto.migrate
```

Now let's follow the directions and add the new resources route to our `web/router.ex` file.

```elixir
defmodule HelloPhoenix.Router do
  use HelloPhoenix.Web, :router

. . .

  scope "/", HelloPhoenix do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
  end

. . .
end

```

When we run `mix test` again, we see that we already have fifteen tests!

```console
$ mix test
Compiled lib/hello_phoenix.ex
Compiled web/models/user.ex
Compiled web/router.ex
Compiled web/views/error_view.ex
Compiled web/controllers/page_controller.ex
Compiled web/views/page_view.ex
Compiled lib/hello_phoenix/endpoint.ex
Compiled web/views/layout_view.ex
Compiled web/controllers/user_controller.ex
Compiled web/views/user_view.ex
Generated hello_phoenix app
...............

Finished in 0.5 seconds (0.4s on load, 0.1s on tests)
15 tests, 0 failures

Randomized with seed 537537
```

At this point, we are at a great place to transition to the rest of the testing guides, in which we'll examine these tests in much more detail, and add some of our own.
