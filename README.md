# Elixir-Mattermost

This library supports the Mattermost WebSocket API and attempts to document the
actual event structure Mattermost sends.  I would refer you to the official
documentation, but it is lacking in websocket specifics.

This library also serves to interact with the Mattermost API.  In order to write
a fully functioning bot or integration, you must use both the Websocket API and
Web API.  An example bot is provided.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mattermost` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:mattermost, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mattermost](https://hexdocs.pm/mattermost).


## Note

This library is based off of the code from https://github.com/BlakeWilliams/Elixir-Slack
