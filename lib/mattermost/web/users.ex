defmodule Mattermost.Web.Users do
  @api "/api/v3/users"

  @api_login "/api/v3/users/login"
  @api_logout "/api/v3/users/logout"

  @api_me "/api/v3/users/me"
  @api_by_name "/api/v3/users/users/name/{username}"
  @api_by_email "/api/v3/users/users/email/{email}"
  @api_by_ids "/api/v3/users/ids"

  @api_create "/api/v3/users/create"
  @api_update "/api/v3/users/update"
  @api_update_roles "/api/v3/users/update_roles"
  @api_update_active "/api/v3/users/update_active"
  @api_update_notify "/api/v3/users/update_notify"
  @api_update_password "/api/v3/users/newpassword"
  @api_password_reset "/api/v3/users/send_password_reset"

  @api_users "/api/v3/users/{offset}/{limit}"
  @api_search "/api/v3/users/search"
  @api_autocomplete "/api/v3/users/autocomplete"


  def login(username, password, mattermost) do
    endpoint = mattermost.url <> @api_login
    pathing = %{}
    payload = %{login_id: username, password: password}

    case Mattermost.Web.raw_request(:post, endpoint, pathing, payload, [], mattermost) do
      {:ok, %{response: json, headers: headers}} ->
        {:ok, %{me: json, token: Mattermost.Web.extract_token(headers)}}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
