defmodule Mattermost.Bot do
  require Logger

  @behaviour :websocket_client

  @moduledoc """
  This module is used to spawn bots and is used to manage the connection to
  Mattermost while delegating events to the specified bot module.
  """

  @doc """
  Connects to Mattermost and delegates events to `bot_handler`.

  ## Options

  * `url` - Mattermost instance url
  * `username` - Login to use for bot
  * `password` - Password for authentication
  * `keepalive` - How long to wait for the connection to respond before the client kills the connection.

  ## Example

  Mattermost.Bot.start_link(Mybot, [1, 2, 3], "abc-123")
  """

  def start_link(bot_handler, initial_state, options \\ %{}) do
    options = Map.merge(%{ client: :websocket_client,
                           keepalive: 10_000,
                           name: nil
                         }, options)

    case Mattermost.Web.Socket.start(options.username, options.password, %Mattermost.State{ url: options.url }) do
      {:ok, mattermost} ->
        socket_state = %{ bot_handler: bot_handler,
                          mattermost: mattermost,
                          client: options.client,
                          initial_state: initial_state }

        {:ok, pid} = options.client.start_link(Mattermost.Web.Socket.wsurl(options.url), __MODULE__, socket_state, [keepalive: options.keepalive])

        if options.name != nil do
          Process.register(pid, options.name)
        end

        {:ok, pid}
      {:error, %HTTPoison.Error{reason: :connect_timeout}} ->
        {:error, "Timed out while connecting to the Mattermost Websocket API"}
      {:error, %HTTPoison.Error{reason: :nxdomain}} ->
        {:error, "Could not connect to the Mattermost Websocket API"}
      {:error, %JSX.DecodeError{string: "You are sending too many requests. Please relax."}} ->
        {:error, "Sent too many connection requests at once to the Mattermost Websocket API."}
      {:error, error} ->
        {:error, error}
    end
  end

  # websocket_client API
  @doc false
  def init(%{bot_handler: bot_handler, mattermost: mattermost, client: client, initial_state: initial_state}) do
    new_mattermost = struct(mattermost, %{ process: self(),
                                           client: client })

    {:reconnect, %{mattermost: new_mattermost, bot_handler: bot_handler, process_state: initial_state}}
  end

  @doc false
  def onconnect(_websocket_request, %{mattermost: mattermost, process_state: process_state, bot_handler: bot_handler} = state) do
    Mattermost.Web.Socket.authentication_challenge(mattermost)
    {:ok, new_process_state} = bot_handler.handle_connect(mattermost, process_state)
    {:ok, %{state | process_state: new_process_state}}
  end

  @doc false
  def ondisconnect(reason, %{mattermost: mattermost, process_state: process_state, bot_handler: bot_handler} = state) do
    try do
      bot_handler.handle_close(reason, mattermost, process_state)
      {:close, reason, state}
    rescue
      e ->
        handle_exception(e)
        {:close, reason, state}
    end
  end

  @doc false
  def websocket_info(message, _connection, %{mattermost: mattermost, process_state: process_state, bot_handler: bot_handler} = state) do
    try do
      {:ok, new_process_state} = bot_handler.handle_info(message, mattermost, process_state)
      {:ok, %{state | process_state: new_process_state}}
    rescue
      e ->
        handle_exception(e)
        {:ok, state}
    end
  end

  @doc false
  def websocket_terminate(_reason, _conn, _state), do: :ok

  @doc false
  def websocket_handle({:text, message}, _conn, %{mattermost: mattermost, process_state: process_state, bot_handler: bot_handler} = state) do
    message = prepare_message(message)

    updated_mattermost = if Map.has_key?(message, :event) do
      Mattermost.State.update(message, mattermost)
    else
      mattermost
    end

    if Map.has_key?(message, :event) do
      try do
        case bot_handler.handle_event(message, updated_mattermost, process_state) do
          {:ok, new_mattermost, new_process_state} ->
            {:ok, %{state | mattermost: new_mattermost, process_state: new_process_state}}
          {:ok, new_process_state} ->
            {:ok, %{state | mattermost: updated_mattermost, process_state: new_process_state}}
        end
      rescue
        e -> handle_exception(e)
      end
    else
      {:ok, %{state | mattermost: updated_mattermost, process_state: process_state}}
    end
  end

  def websocket_handle(message, _conn, state) do
    {:ok, state}
  end

  defp prepare_message(binstring) do
    binstring
      |> :binary.split(<<0>>)
      |> List.first
      |> JSX.decode!([{:labels, :atom}])
  end

  defp handle_exception(e) do
    message = Exception.message(e)
    Logger.error(message)
    System.stacktrace |> Exception.format_stacktrace |> Logger.error
    raise message
  end
end
