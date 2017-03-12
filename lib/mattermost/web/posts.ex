defmodule Mattermost.Web.Posts do

  ####################################################################
  @api_create "/api/v3/teams/{{team_id}}/channels/{{channel_id}}/posts/create" # POST
  @doc """
  Create a post in a channel
  """
  def create(team_id, channel_id, message, mattermost) do
    endpoint = mattermost.url <> @api_create
    pathing = %{team_id: team_id, channel_id: channel_id}
    payload = %{channel_id: channel_id, message: message}

    Mattermost.Web.post(endpoint, pathing, payload, [], mattermost)
  end
end
