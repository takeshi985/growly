# Backend

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Growly browser demo

After setup and server startup, open
[`localhost:4000/demo`](http://localhost:4000/demo).

The prototype demonstrates the child learning flow, gentle hints, parent
progress reporting, initial diagnostic, and safe demo-progress reset. It is the
browser validation stage before the Flutter mobile client.

## Internal content admin

Open [`localhost:4000/admin/content`](http://localhost:4000/admin/content) to
manage Growly skills and tasks from the browser. Task answer options use one
`key=value` pair per line in the editor.

Authentication is not implemented yet. Content Admin is an internal MVP tool
for preparing educational content before the mobile application is built and
must not be exposed as a public production admin panel.

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
