defmodule MattermostWebTest do
  use ExUnit.Case
  doctest Mattermost.Web

  @json_headers [{"Content-Type", "application/json"}]
  @json_payload %{item: "foo", key: "bar"}


  #
  # create_headers/2
  #
  test "create_payload with parameters" do
    assert "{\"item\":\"foo\",\"key\":\"bar\"}" == Mattermost.Web.create_payload(@json_payload)
  end

  test "create_payload with no parameters" do
    assert "{}" == Mattermost.Web.create_payload()
  end


  #
  # create_headers/2
  #
  test "create_headers with no token or headers" do
    assert @json_headers == Mattermost.Web.create_headers([], nil)
  end

  test "create_headers with no token" do
    extra = [{"X-Forwarded-For", "127.0.0.1"}]
    assert extra ++ @json_headers == Mattermost.Web.create_headers(extra, nil)
  end

  test "create_headers with nil token" do
    assert @json_headers == Mattermost.Web.create_headers([], %Mattermost.State{token: nil})
  end

  test "create_headers with token" do
    assert [{"Authorization", "Bearer 123"}] ++ @json_headers == Mattermost.Web.create_headers([], %Mattermost.State{token: "123"})
  end


  #
  # extract_token/1
  #
  test "extract_token with no headers" do
    assert nil == Mattermost.Web.extract_token([])
  end

  test "extract_token with no token headers" do
    assert nil == Mattermost.Web.extract_token([{"Set-Cookie", "123"}])
  end

  test "extract_token with token header" do
    assert "123" == Mattermost.Web.extract_token([{"Token", "123"}])
  end


  #
  # _extract_token_from/1
  #
  test "_extract_token_from without a token" do
    assert nil == Mattermost.Web._extract_token_from({"Not a token", "okay"})
  end

  test "_extract_token_from with a token header" do
    assert "123" == Mattermost.Web._extract_token_from({"Token", "123"})
  end
end
