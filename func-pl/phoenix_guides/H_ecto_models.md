Most web applications today need some form of data storage. In the Elixir ecosystem, we have Ecto to enable this. Ecto currently has adapters for the following databases:

* PostgreSQL
* MySQL
* MSSQL
* SQLite3
* MongoDB

Newly generated Phoenix applications integrate both Ecto and the PostgreSQL adapter by default.

This guide assumes that we have generated our new application with Ecto. If we're using an older Phoenix app, or we used the `--no-ecto` option to generate our application, all is not lost. Please follow the instructions in the "Integrating Ecto into an Existing Application" section below.

This guide also assumes that we will be using PostgreSQL. For instructions on switching to MySQL, please see the [Using MySQL Guide](http://www.phoenixframework.org/docs/using-mysql).

Now that we all have Ecto and Postgrex installed and configured, the easiest way to use Ecto models is to generate a resource through the `phoenix.gen.html` task. Let's generate a `User` resource with `name`, `email`, `bio`, and `number_of_pets` fields.

```console
$ mix phoenix.gen.html User users name:string email:string bio:string number_of_pets:integer
* creating priv/repo/migrations/20150409213440_create_user.exs
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

Add the resource to your browser scope in web/router.ex:

    resources "/users", UserController

and then update your repository by running migrations:

    $ mix ecto.migrate
```

Notice that we get a lot for free with this task - a migration, a controller, a controller test, a model, a model test, a view, and a number of templates.

Let's follow the instructions the task gives us and insert the `resources "/users", UserController` line in the router `web/router.ex`.

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

With the resource route in place, it's time to run our migration.

```console
$ mix ecto.migrate
Compiled lib/hello_phoenix.ex
Compiled web/models/user.ex
Compiled web/views/error_view.ex
Compiled web/controllers/page_controller.ex
Compiled web/views/page_view.ex
Compiled web/router.ex
Compiled web/views/layout_view.ex
Compiled web/controllers/user_controller.ex
Compiled lib/hello_phoenix/endpoint.ex
Compiled web/views/user_view.ex
Generated hello_phoenix.app
** (Postgrex.Error) FATAL (invalid_catalog_name): database "hello_phoenix_dev" does not exist
    lib/ecto/adapters/sql/worker.ex:29: Ecto.Adapters.SQL.Worker.query!/4
    lib/ecto/adapters/sql.ex:187: Ecto.Adapters.SQL.use_worker/3
    lib/ecto/adapters/postgres.ex:58: Ecto.Adapters.Postgres.ddl_exists?/3
    lib/ecto/migration/schema_migration.ex:19: Ecto.Migration.SchemaMigration.ensure_schema_migrations_table!/1
    lib/ecto/migrator.ex:36: Ecto.Migrator.migrated_versions/1
    lib/ecto/migrator.ex:134: Ecto.Migrator.run/4
    (mix) lib/mix/cli.ex:55: Mix.CLI.run_task/2
```

Oops! This error message means that we haven't created the database that Ecto expects by default. In our case, the database we need is called `hello_phoenix_dev` - that is the name of our application with a `_dev` suffix indicating that it is our development database.

Ecto has an easy way to do this. We just run the `ecto.create` task.

```console
$ mix ecto.create
The database for repo HelloPhoenix.Repo has been created.
```

Mix assumes that we are in the development environment unless we tell it otherwise with `MIX_ENV=another_environment`. Our Ecto task will get its environment from Mix, and that's how we get the correct suffix to our database name.

Now our migration should run more smoothly.

```console
$ mix ecto.migrate
[info] == Running HelloPhoenix.Repo.Migrations.CreateUser.change/0 forward
[info] create table users
[info] == Migrated in 0.3s
```

Before we get too far into the details, let's have some fun! We can start our server with `mix phoenix.server` at the root of our project and then head to the [users index](http://localhost:4000/users) page. We can click on "New user" to create new users, then show, edit, or delete them. By default, Ecto considers all of the fields on our model to be required. (We'll see how to change that in a bit.) If we don't provide some of them when creating or updating, we'll see a nice error message telling us all of the fields we missed. Our resource generating task has given us a complete scaffold for manipulating user records in the database and displaying the results.

Ok, now back to the details.

If we log in to our database server, and connect to our `hello_phoenix_dev` database, we should see our `users` table. Ecto assumes that we want an integer column called `id` as our primary key, so we should see a sequence generated for that as well.

```console
=# \connect hello_phoenix_dev
You are now connected to database "hello_phoenix_dev" as user "postgres".
hello_phoenix_dev=# \d
List of relations
Schema |       Name        |   Type   |  Owner
--------+-------------------+----------+----------
public | schema_migrations | table    | postgres
public | users             | table    | postgres
public | users_id_seq      | sequence | postgres
(3 rows)
```

If we take a look at the migration generated by `phoenix.gen.html`, we'll see that it will add the columns we specified. It will also add timestamp columns for `inserted_at` and `updated_at` which come from the `timestamps/0` function.

```elixir
defmodule HelloPhoenix.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :bio, :string
      add :number_of_pets, :integer

      timestamps
    end
  end
end

```

And here's what that translates to in the actual `users` table.

```console
hello_phoenix_dev=# \d users
Table "public.users"
Column     |            Type             |                     Modifiers
----------------+-----------------------------+----------------------------------------------------
id             | integer                     | not null default nextval('users_id_seq'::regclass)
name           | character varying(255)      |
email          | character varying(255)      |
bio            | character varying(255)      |
number_of_pets | integer                     |
inserted_at    | timestamp without time zone | not null
updated_at     | timestamp without time zone | not null
Indexes:
"users_pkey" PRIMARY KEY, btree (id)
```

Notice that we do get an `id` column as our primary key by default, even though it isn't listed as a field in our migration.

#### The Repo

Our `HelloPhoenix.Repo` module is the foundation we need to work with databases in a Phoenix application. Phoenix generated it for us here `lib/hello_phoenix/repo.ex`, and this is what it looks like.

```elixir
defmodule HelloPhoenix.Repo do
  use Ecto.Repo, otp_app: :hello_phoenix
end
```

Our repo has two main tasks - to bring in all the common query functions from `Ecto.Repo` and to set the `otp_app` name equal to our application name.

When `phoenix.new` generated our application, it also generated some basic configuration as well. Let's look at `config/dev.exs`.

```elixir
. . .
# Configure your database
config :hello_phoenix, HelloPhoenix.Repo,
adapter: Ecto.Adapters.Postgres,
username: "postgres",
password: "postgres",
database: "hello_phoenix_dev"
. . .
```

It begins by configuring our `otp_app` name and repo module. Then it sets the adapter - Postgres, in our case. It also sets our login credentials. Of course, we can change these to match our actual credentials if they are different.

We also have similar configuration in `config/test.exs` and `config/prod.secret.exs` which can also be changed to match our actual credentials.

#### The Model

Ecto models have several functions. Each model defines the fields of our schema as well as their types. They each define a struct with the same fields in our schema. Models are where we define relationships with other models. Our `User` model might have many `Post` models, and each `Post` would belong to a `User`. Models also handle data validation and type casting with changesets.

Here is the `User` model that Phoenix generated for us.

```elixir
defmodule HelloPhoenix.User do
  use HelloPhoenix.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :bio, :string
    field :number_of_pets, :integer

    timestamps
  end

  @required_fields ~w(name email bio number_of_pets)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

```

The schema block at the top of the model should be pretty self-explanatory. We'll take a look at changesets next.

#### Changesets and Validations

Changesets define a pipeline of transformations our data needs to undergo before it will be ready for our application to use. These transformations might include type casting, validation, and filtering out any extraneous parameters.

Let's take a closer look at our default changeset.

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
end
```

At this point, we only have one transformation in our pipeline. This `cast/4` function's main job is to separate required fields from optional ones. We define the fields for each category in the module attributes `@required_fields` and `@optional_fields`. By default all of the fields are required.

Let's take a look at two ways to validate that this is the case. The first and easiest way is to simply start our application by running the `mix phoenix.server` task at the root of our project. Then we can go to the [new users page](http://localhost:4000/users/new) and click the "submit" button without filling in any fields. We should get an error telling us that something went wrong and enumerating all the fields which can't be blank. That should be all the fields in our schema at this point.

We can also verify this in iex. Let's stop our server and start it again with `iex -S mix phoenix.server`. In order to minimize typing and make this easier to read, let's alias our `HelloPhoenix.User` model.

```console
iex(1)> alias HelloPhoenix.User
nil
```

Then let's create a changeset from our model with an empty `User` struct, and an empty map of parameters.

```console
iex(2)> changeset = User.changeset(%User{}, %{})
%Ecto.Changeset{action: nil, changes: %{}, constraints: [],
 errors: [name: "can't be blank", email: "can't be blank",
  bio: "can't be blank", number_of_pets: "can't be blank"], filters: %{},
 model: %HelloPhoenix.User{__meta__: #Ecto.Schema.Metadata<:built>, bio: nil,
  email: nil, id: nil, inserted_at: nil, name: nil, number_of_pets: nil,
  updated_at: nil}, optional: [], params: %{}, repo: nil,
 required: [:name, :email, :bio, :number_of_pets],
 types: %{bio: :string, email: :string, id: :id, inserted_at: Ecto.DateTime,
   name: :string, number_of_pets: :integer, updated_at: Ecto.DateTime},
 valid?: false, validations: []}
```

Once we have a changeset, we can ask it if it is valid.

```console
iex(3)> changeset.valid?
false
```

Since this one is not valid, we can ask it what the errors are.

```console
iex(4)> changeset.errors
[name: "can't be blank", email: "can't be blank",
bio: "can't be blank", number_of_pets: "can't be blank"]
```

It gives us the same list of fields that can't be blank that we got from the front end of our application.

Now let's test this by moving the `number_of_pets` field from `@required_fields` to `@optional_fields`.

```elixir
@required_fields ~w(name email bio)
@optional_fields ~w(number_of_pets)
```

Now either method of verification should tell us that only `name`, `email`, and `bio` can't be blank.

What happens if we pass a key/value pair that is in neither `@required_fields` nor `@optional_fields`? Let's find out.

In a new `iex -S mix phoenix.server` session, we should alias our module again.

```console
iex(1)> alias HelloPhoenix.User
nil
```

Lets create a `params` map with valid values plus an extra `random_key: "random value"`.

```console
iex(2)> params = %{name: "Joe Example", email: "joe@example.com", bio: "An example to all", number_of_pets: 5, random_key: "random value"}
%{email: "joe@example.com", name: "Joe Example", bio: "An example to all",
number_of_pets: 5, random_key: "random value"}
```

Then let's use our new `params` map to create a changeset.

```console
iex(3)> changeset = User.changeset(%User{}, params)
%Ecto.Changeset{action: nil,
 changes: %{bio: "An example to all", email: "joe@example.com",
   name: "Joe Example", number_of_pets: 5}, constraints: [], errors: [],
 filters: %{},
 model: %HelloPhoenix.User{__meta__: #Ecto.Schema.Metadata<:built>, bio: nil,
  email: nil, id: nil, inserted_at: nil, name: nil, number_of_pets: nil,
  updated_at: nil}, optional: [:number_of_pets],
 params: %{"bio" => "An example to all", "email" => "joe@example.com",
   "name" => "Joe Example", "number_of_pets" => 5,
   "random_key" => "random value"}, repo: nil, required: [:name, :email, :bio],
 types: %{bio: :string, email: :string, id: :id, inserted_at: Ecto.DateTime,
   name: :string, number_of_pets: :integer, updated_at: Ecto.DateTime},
 valid?: true, validations: []}
```

Our new changeset is valid.

```console
iex(4)> changeset.valid?
true
```

We can also check the changeset's changes - the map we get after all of the transformations are complete.

```console
iex(9)> changeset.changes
%{bio: "An example to all", email: "joe@example.com", name: "Joe Example",
number_of_pets: 5}
```

Notice that our `random_key` and `random_value` have been removed from our final changeset.

We can validate more than just whether a field is required or not. Let's take a look at some finer-grained validations.

What if we had a requirement that all biographies in our system must be at least two characters long? We can do this easily by adding another transformation to the pipeline in our changeset which validates the length of the `bio` field.

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_length(:bio, min: 2)
end
```

Now if we try to add a new user through the front end of the application with a bio of "A", we should see this error message at the top of the page.

```text
Oops, something went wrong! Please check the errors below:
Bio should be at least 2 characters
```

If we also have a requirement for the maximum length that a bio can have, we can simply add another validation.

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_length(:bio, min: 2)
  |> validate_length(:bio, max: 140)
end
```

Now if we try to add a new user with a 141 character bio, we would see this error.

```text
Oops, something went wrong! Please check the errors below:
Bio should be at most 140 characters
```

Let's say we want to perform at least some rudimentary format validation on the `email` field. All we want to check for is the presence of the "@". The `validate_format/3` function is just what we need.

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_length(:bio, min: 2)
  |> validate_length(:bio, max: 140)
  |> validate_format(:email, ~r/@/)
end
```

If we try to create a user with an email of "personexample.com", we should see an error message like the following.

```text
Oops, something went wrong! Please check the errors below:
Email has invalid format
```

There are many more validations and transformations we can perform in a changeset. Please see the [Ecto Changeset documentation](http://hexdocs.pm/ecto/Ecto.Changeset.html) for more information.

#### Controller Usage

At this point, let's see how we can actually use Ecto in our application. Luckily, Phoenix gave us an example of this when we ran `mix phoenix.gen.html`, the `HelloPhoenix.UserController`.

Let's work through the generated controller action by action to see how Ecto is used.

Before we get to the first action, let's look at two important lines at the top of the file.

```elixir
defmodule HelloPhoenix.UserController do
. . .
  alias HelloPhoenix.User

  plug :scrub_params, "user" when action in [:create, :update]
. . .
end
```

We alias `HelloPhoenix.User` so that we can name our structs `%User{}` instead of `%HelloPhoenix.User{}`.

We also plug the `Phoenix.Controller.scrub_params/2` to pre-process our params a bit before they come to an action. `scrub_params/2` does a couple of useful things for us. It makes sure that all of the required fields are present, and raises an error for each that is missing. It will also recursively change any empty strings to nils.

On to our first action, `index`.

```elixir
def index(conn, _params) do
  users = Repo.all(User)
  render(conn, "index.html", users: users)
end
```

The whole purpose of this action is to get all of the users from the database and display them in the `index.html.eex` template. We use the built-in `Repo.all/1` query to do that, and we pass in the (aliased) model name. It's that simple.

Notice that we do not use a changeset here. The assumption is that data will have to pass through a changeset in order to get into the database, so data coming out should already be valid.

Now, on to the `new` action. Notice that we do use a changeset, even though we do not use any parameters when we create it. Essentially, we always create an empty changeset in this action. The reason for this is that `new.html` can be rendered here, but it can also be rendered if we have invalid data in the `create` action. The changeset will then contain errors that we need to display back to the user. We render `new.html` with a changeset in both places for consistency.

```elixir
def new(conn, _params) do
  changeset = User.changeset(%User{})
  render(conn, "new.html", changeset: changeset)
end
```

Once a user submits the form rendered from `new.html` above, the form elements and their values will be posted as parameters to the `create` action. This action shares some steps with the iex experiments that we did above.

```elixir
def create(conn, %{"user" => user_params}) do
  changeset = User.changeset(%User{}, user_params)

  case Repo.insert(changeset) do
    {:ok, _user} ->
      conn
      |> put_flash(:info, "User created successfully.")
      |> redirect(to: user_path(conn, :index))
    {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
  end
end
```

Notice that we get the user parameters by pattern matching with the `"user"` key in the function signature. Then we create a changeset with those params and call `Repo.insert/1`. If the changeset is valid, it will return `{:ok, user}` with the inserted user model, then we set a flash message, and redirect to the `index` action.

If insert errored, we re-render `new.html` with the changeset to display the errors to the user.

In the `show` action, we use the `Repo.get!/2` built-in function to fetch the user record identified by the id we get from the request parameters. We don't generate a changeset here because we assume that the data has passed through a changeset on the way in to the database, and therefore is valid when we retrieve it here.

This is the singular version of `index` above.

```elixir
def show(conn, %{"id" => id}) do
  user = Repo.get!(User, id)
  render(conn, "show.html", user: user)
end
```

In the `edit` action, we use Ecto in a way which is a combination of `show` and `new`. We pattern match for the `id` from the incoming params so that we can use `Repo.get!/2` to retrieve the correct user from the database, as we did in `show`. We also create a changeset from that user because when the user submits a `PUT` request to `update`, there might be errors, which we can track in the changeset when re-rendering `edit.html`.

```elixir
def edit(conn, %{"id" => id}) do
  user = Repo.get!(User, id)
  changeset = User.changeset(user)
  render(conn, "edit.html", user: user, changeset: changeset)
end
```

The `update` action is nearly identical to `create`. The only difference is that we use `Repo.update/1` instead of `Repo.insert/1`. `Repo.update/1`, when used with a changeset, keeps track of fields which have changed. If no fields have changed, `Repo.update/1` won't send any data to the database. `Repo.insert/1` will always send all the data to the database.

```elixir
def update(conn, %{"id" => id, "user" => user_params}) do
  user = Repo.get!(User, id)
  changeset = User.changeset(user, user_params)

  case Repo.update(changeset) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "User updated successfully.")
      |> redirect(to: user_path(conn, :show, user))
    {:error, changeset} ->
      render(conn, "edit.html", user: user, changeset: changeset)
  end
end
```

Finally, we come to the `delete` action. Here we also pattern match for the record id from the incoming params in order to use `Repo.get!/2` to fetch the user. From there, we simply call `Repo.delete!/1`, set a flash message, and redirect to the `index` action.

Note: There is nothing in this generated code to allow a user to change their mind about the deletion. In other words, there is no "Are you sure?" modal, so an errant mouse click will delete data without further warning. It's up to us as developers to add this in ourselves if we feel we need it.

```elixir
def delete(conn, %{"id" => id}) do
  user = Repo.get!(User, id)

  # Here we use delete! (with a bang) because we expect
  # it to always work (and if it does not, it will raise).
  Repo.delete!(user)

  conn
  |> put_flash(:info, "User deleted successfully.")
  |> redirect(to: user_path(conn, :index))
end
```

That's the end of our walk-through of Ecto usage in our controller actions. There is quite a bit more that Ecto models can do. Please take a look at the [Ecto documentation](http://hexdocs.pm/ecto/) for the rest of the story.

### Data Relationship and Dependencies

Suppose we are building a very simple video-sharing web application, in addition to having users on our site, we might also want to have videos. We asked Phoenix to scaffold a `Video` model for us:

```console
$ mix phoenix.gen.model Video videos name:string approved_at:datetime description:text likes:integer views:integer user_id:references:users
* creating priv/repo/migrations/20150611051558_create_video.exs
* creating web/models/video.ex
* creating test/models/video_test.exs

$ mix ecto.migrate
```

Handling individual tables is great, but if we want to build a modern web application, we will need a way to relate our data to each other. Those of us with experience using Ruby's ActiveRecord will be glad to see that Ecto provides a very familiar API for building relationships. For example,

`Schema.has_many/3` declares one to many relationships, for example, in our video sharing service, our user model might have many uploaded video models.

`Schema.belongs_to/3` declares a one to one relationship between parent and children models. In our video site example, an uploaded video belongs to its user.

`Schema.has_one/3` declares a one to one relationship. Note that has_one is just like has_many except instead of returning a collection of model structs, we get just one model struct. Continuing with the video-sharing example, while a user might have many uploaded videos, the user might only have one featured video.

Here's how we would declare a `has_many` relationship in `web/models/user.ex`:
```elixir
defmodule HelloPhoenix.User do
. . .
  schema "users" do
    field :name, :string
    field :email, :string
    field :bio, :string
    field :number_of_pets, :integer

    has_many :videos, HelloPhoenix.Video
    timestamps
  end
. . .
end
```

Since we used the generator to scaffold our `Video` model and specified the user association with `user_id:references:users`, the `belongs_to` relationship will already be defined for us in `web/models/video.ex`:
```elixir
defmodule HelloPhoenix.Video do
. . .
  schema "videos" do
    field :name, :string
    field :approved_at, Ecto.DateTime
    field :description, :string
    field :likes, :integer
    field :views, :integer
    belongs_to :user, HelloPhoenix.User

    timestamps
  end
  @required_fields ~w(name approved_at description user_id)
. . .
end
```
Note that we don't declare the field `user_id` in the video model schema. We add it to the required (or optional) field list instead.

We can use our newly declared relationships in our `web/controllers/user_controller.ex` like this:

```elixir
defmodule HelloPhoenix.UserController do
. . .
  def index(conn, _params) do
    users = User |> Repo.all |> Repo.preload [:videos]
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = User |> Repo.get!(id) |> Repo.preload [:videos]
    render(conn, "show.html", user: user)
  end
. . .
end
```
Because we declared a relationship in `HelloPhoenix.User`, `%User{}` will now contain a videos property which starts out as an unloaded relationship. In order to properly display it in `render`, we'll need to tell Ecto to preload the field. Note that `Repo.preload/2` is smart enough to work on just one model or collection of them.

### Working with Callback Hooks

Continuing with our video sharing app example, many web applications require moderation for user submitted content. Our Video model has an `approved_at` field to signify that a moderator has approved the video. The question is, what happens if the user edits the video? Ideally, we'd like to be able to "null out" a video's `approved_at` field when this happens. Fortunately, Ecto provides us with a handful of life-cycle callbacks to achieve this.

We will instruct Ecto to use the `before_update` hook in `web/models/video.ex` like so:

```elixir
defmodule HelloPhoenix.Video do
. . .
  before_update :reset_approved_at
  def reset_approved_at(changeset) do
    changeset
    |> Ecto.Changeset.put_change(:approved_at, nil)
  end
end
```
Now, when `Repo.update` is called for the `Video` model, the `approved_at` field will automatically be reset to nil. This should keep us safe from the ravages of an often hostile modern Internet!

`Ecto.Model.Callbacks` actually ships with a lot more than the `before_update` callback, in addition, it comes with:

- `before_delete`: called before the adapter deletes our record from the database; if perhaps we have a foreign_key constraint from another table, we would use this hook to clean it up.
- `after_delete`: called after the adapter deletes our record. If we wished to archive our record, we'd do it in this hook.
- `before_update`: called before the adapter updates our record. We used it above to "null out" a video's `approved_at` field.
- `after_update`: called after the adapter updates our record. If we wanted to notify user that the model has changed, we would do that here.
- `before_insert`: called before the adapter first creates a new record. We would use it in cases when we wanted to infer default values to certain fields from the partial changeset we receive from the user.
- `after_insert`: called after the adapter creates our record. We could use this to notify the user a new video has been created under that user's account.
- `after_load`: called after the model is loaded from the database. We might use this to load in other values based upon what we found in our record.

Note: there is no `before_load` hook.

In all cases, a hook expects to be passed an atom that is the name of the function it is to call if that function is defined in the current module:

```elixir
before_insert :name_of_function_to_call
def name_of_function_to_call(changeset) do
  # do stuff with the changeset
  # and return the modified changeset
end
```
If our callback function lives elsewhere, hooks can take the name of the module as the first argument:
```elixir
before_insert HelloPhoenix.AnotherPlace, :name_of_function_to_call
```

Our callback function must always take a changeset as its first argument, and return a changeset. In our callbacks, we can expect to often be calling `Ecto.Changeset` functions like:

- `put_change(changeset, key, value)`
- `get_field(changeset, key, defaultValue//nil)`
- `add_error(changeset, key, error)`

For the full reference, visit the docs at [Ecto Changeset documentation](http://hexdocs.pm/ecto/Ecto.Changeset.html).

Ecto callbacks can be very powerful, but we need to be careful when using them. On one hand, they can add behaviors in a way which may not be apparent in the execution flow because callbacks can be defined far from the action in our model. On the other hand, it might seem tempting to put a lot of behavior in a single callback, which can make the model difficult to test and debug.

### Integrating Ecto into an Existing Application

Adding Ecto to an existing Phoenix application which wasn't using it before is easy. Once we include Ecto and Postgrex as dependencies, there are mix tasks to help us.

#### Adding Ecto and Postgrex as Dependencies

We can add Ecto by way of the `phoenix_ecto` package, and we can add the `postgrex` package directly, just as we would add any other dependencies to our project.

```elixir
defmodule HelloPhoenix.Mixfile do
  use Mix.Project

. . .
  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.0.2"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"}]
  end
end
```

Then we run `mix do deps.get, compile` to get them into our application.

```console
$ mix do deps.get, compile
Running dependency resolution
Dependency resolution completed successfully
. . .
```

The next piece we need to add is our application's repo. We can easily do that with the `ecto.gen.repo` task.

```console
$ mix ecto.gen.repo
* creating lib/hello_phoenix
* creating lib/hello_phoenix/repo.ex
* updating config/config.exs
Don't forget to add your new repo to your supervision tree
(typically in lib/hello_phoenix.ex):

worker(HelloPhoenix.Repo, [])
```

Note: Please see the "Repo" section above for information on what the repo does.

This task creates a directory for our repo as well as the repo itself.

```elixir
defmodule HelloPhoenix.Repo do
  use Ecto.Repo, otp_app: :hello_phoenix
end
```

It also adds this block of configuration to our `config/config.exs` file. If we have different configuration options for different environments (which we should), we'll need to add a block like this to `config/dev.exs`, `config/test.exs`, and `config/prod.secret.exs` with the correct values.

```elixir
. . .
config :hello_phoenix, HelloPhoenix.Repo,
adapter: Ecto.Adapters.Postgres,
database: "hello_phoenix_repo",
username: "user",
password: "pass",
hostname: "localhost"
```

We should also make sure to listen to the output of `ecto.gen.repo` and add our application repo as a child worker to our application's supervision tree.

Let's open up `lib/hello_phoenix.ex` and do that by adding `worker(HelloPhoenix.Repo, [])` to the list of children our application will start.

```elixir
defmodule HelloPhoenix do
  use Application
. . .
    children = [
      # Start the endpoint when the application starts
      supervisor(HelloPhoenix.Endpoint, []),
      # Start the Ecto repository
      worker(HelloPhoenix.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(HelloPhoenix.Worker, [arg1, arg2, arg3]),
    ]
. . .
end
```

At this point, we are completely configured and ready to go. We can go back to the top of this guide and follow along.
