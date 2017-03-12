defmodule JSX.DecodeError do
  defexception [:reason, :string]

  def message(%JSX.DecodeError{reason: reason, string: string}) do
    "JSX could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Mattermost.Web do
  @moduledoc false

  require Logger


  ####################################################################
  def request(method, endpoint, pathing, payload, headers, state) do
    case raw_request(method, endpoint, pathing, payload, headers, state) do
      {:ok, %{response: json, headers: headers}} ->
        {:ok, json}
      {:error, reason} ->
        {:error, reason}
    end
  end
  def raw_request(method, endpoint, pathing, payload, headers, state) do
    request_endpoint = Mustache.render(endpoint, pathing)
    request_headers = create_headers(headers, state)


    response = case method do
                 :get ->
                   HTTPoison.get(request_endpoint, request_headers)
                 :post ->
                   request_payload = create_payload(payload)
                   HTTPoison.post(request_endpoint, request_payload, request_headers)
               end

    case response do
      {:ok, %HTTPoison.Response{body: body, headers: headers}} ->
        case JSX.decode(body, [{:labels, :atom}]) do
          {:ok, json}       -> {:ok, %{response: json, headers: headers}}
          {:error, reason}  -> {:error, %JSX.DecodeError{reason: reason, string: body}}
        end
      {:error, reason} -> {:error, reason}
    end
  end


  ####################################################################
  def get(endpoint, pathing, payload, headers, mattermost) do
    request(:get, endpoint, pathing, payload, headers, mattermost)
  end

  def post(endpoint, pathing, payload, headers, mattermost) do
    request(:post, endpoint, pathing, payload, headers, mattermost)
  end


  ####################################################################
  def create_payload(params \\ %{}) do
    case JSX.encode(params) do
      {:ok, json} ->
        json
      error ->
        message = """
        Failed to generate JSON payload for authentication: #{inspect params, pretty: true}
        JSX error: #{inspect error, pretty: true}
        """
        Logger.error(message)
        raise RuntimeError, message: message
    end
  end


  ####################################################################
  def create_headers(headers, nil) do
    headers ++ [{"Content-Type", "application/json"}]
  end
  def create_headers(headers, %{token: nil}) do
    create_headers(headers, nil)
  end
  def create_headers(headers, %{token: token}) do
    create_headers(headers ++ [{"Authorization", "Bearer " <> token}], nil)
  end


  ####################################################################
  @spec extract_token(list(tuple)) :: String.t
  def extract_token([]) do
    nil
  end
  def extract_token(headers) do
    _extract_token_from(Enum.find(headers, nil, fn
          {"Token", _} -> true
          _ -> false
        end))
  end


  ####################################################################
  @spec _extract_token_from(tuple) :: String.t
  def _extract_token_from({"Token", token}) do
    token
  end
  def _extract_token_from(_) do
    nil
  end


  ####################################################################
  @doc """
  Convert a Mattermost list response into a map
  """
  def list_to_map(list) do
    Enum.reduce(list, %{}, fn (item, map) ->
      Map.put(map, item.id, item)
    end)
  end
end
