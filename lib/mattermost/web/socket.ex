#
# It was hard to find documentation on the actual WebSocket events so here is
# what I've seen so far through the logs:
defmodule Mattermost.Web.Socket do
  @moduledoc false

  require Logger

  def start(username, password, mattermost) do
    case Mattermost.Web.Users.login(username, password, mattermost) do
      {:ok, result} ->
        {:ok, struct(mattermost, %{me: result.me, token: result.token})}
      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Returns an approprite web socket url for the mattermost instance at `url`.
  """
  def wsurl("https" <> url) do
    wsurl("wss" <> url)
  end
  def wsurl("http" <> url) do
    wsurl("ws" <> url)
  end
  def wsurl(url) do
    String.to_char_list(url <> "/api/v3/users/websocket")
  end


  @doc """
  Sends the authentication challenge to the given `mattermost` client web
  socket.
  """
  def authentication_challenge(mattermost) do
    send_request("authentication_challenge", %{token: mattermost.token}, mattermost)
  end


  @doc """
  Sends a request through the web socket for the given `mattermost` connection.
  """
  def send_request(action, data, mattermost) do
    %{ action: action,
       seq: 1,
       data: data
    }
    |> JSX.encode!
    |> send_raw(mattermost)
  end


  @doc """
  Send raw JSON to the client socket.
  """
  def send_raw(json, %{process: pid, client: client}) do
    IO.puts "sending: #{inspect json, pretty: true}"
    client.cast(pid, {:text, json})
  end
end
