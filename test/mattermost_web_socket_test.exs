defmodule MattermostWebSocketTest do
  use ExUnit.Case
  doctest Mattermost.Web.Socket

  @url_base "://localhost:8065"
  @url "://localhost:8065/api/v3/users/websocket"

  #
  # url/1
  #
  test "websocket_url with https" do
    assert String.to_char_list("wss" <> @url) == Mattermost.Web.Socket.wsurl("https" <> @url_base)
  end

  test "websocket_url with http" do
    assert String.to_char_list("ws" <> @url) == Mattermost.Web.Socket.wsurl("http" <> @url_base)
  end

  test "websocket_url with existing wss" do
    assert String.to_char_list("wss" <> @url) == Mattermost.Web.Socket.wsurl("wss" <> @url_base)
  end

  test "websocket_url with existing ws" do
    assert String.to_char_list("ws" <> @url) == Mattermost.Web.Socket.wsurl("ws" <> @url_base)
  end
end
