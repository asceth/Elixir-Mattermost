defmodule Mattermost do
  @moduledoc """
  Mattermost is a genserver-ish interface for working with the Mattermost
  API through a Websocket connection.

  To use this module you'll need:
  * Mattermost instance url
  * User name
  * Password


  ## Example
  ```
  defmodule Bot do
    use Mattermost

    def handle_event(message = %{type: "message"}, mattermost, state) do
      if message.text == "Hi" do
        send_message("Hello to you too!", message.channel, mattermost)
      end

      {:ok, state}
    end

    def handle_event(_, _, state), do: {:ok, state}
    end
  end

  Mattermost.Bot.start_link(Bot, [], "MATTERMOST_URL", "MATTERMOST_USER", "MATTERMOST_PASSWORD")

  `handle_*` methods are always passed `mattermost` and `state` arguments. The
  `mattermost` argument holds the state of Mattermost and is kept up to date
  automatically.

  In this example we're just matching against the message type and checking if
  the text content is "Hi" and if so, we reply with our own greeting.

  The message type is pattern matched against because the
  [Mattermost WebSocket API](https://api.mattermost.com/#tag/WebSocket) defines
  many different types of messages that we can receive.  Because of this it's
  wise to write a catch-all `handle_events/3` in your bots to prevent crashing.

  ## Callbacks

  * `handle_connect(mattermost, state)` - called when connected to Mattermost.
  * `handle_event(message, mattermost, state)` - called when a message is received.
  * `handle_close(reason, mattermost, state)` - called when websocket is closed before process is terminated.
  * `handle_info(message, mattermost, state)` - called when any other message is received in the process mailbox.

  ## Mattermost argument

  The Mattermost argument that's passed to each callback is what contains all of the
  state related to Mattermost including a list of channels, users, groups, bots, and
  even the socket.

  Here's a list of what's stored:

  * me - The current bot/users information stored as a map of properties.
  * team - The current team's information stored as a map of properties.
  * channels - Stored as a map with id's as keys.
  * groups - Stored as a map with id's as keys.
  * users - Stored as a map with id's as keys.
  * ims (direct message channels) - Stored as a map with id's as keys.
  * socket - The connection to Mattermost.
  * client - The client that makes calls to Mattermost.
  ```
  """

  defmacro __using__(_) do
    quote do
      import Mattermost
      import Mattermost.Lookups

      def handle_connect(_mattermost, state), do: {:ok, state}
      def handle_event(_message, _mattermost, state), do: {:ok, state}
      def handle_close(_reason, _mattermost, state), do: :close
      def handle_info(_message, _mattermost, state), do: {:ok, state}

      defoverridable [handle_connect: 2, handle_event: 3, handle_close: 3, handle_info: 3]
    end
  end
end
