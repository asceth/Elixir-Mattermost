defmodule Mattermost.Web.Channels do

  ####################################################################
  @api_create "/api/v3/teams/{{team_id}}/channels/create" # POST
  @doc """
  Create a channel
  """

  ####################################################################
  @api_update "/api/v3/teams/{{team_id}}/channels/{{channel_id}}/update" # POST
  @doc """
  Update a channel
  """

  ####################################################################
  @api_view "/api/v3/teams/{{team_id}}/channels/view" # POST
  @doc """
  View a channel
  """

  ####################################################################
  @api_all "/api/v3/teams/{{team_id}}/channels/" # GET
  @doc """
  Get a list of channels for a team that the logged in user is a part of
  """
  def all(team_id, mattermost) do
    endpoint = mattermost.url <> @api_all
    pathing = %{team_id: team_id}
    payload = %{}

    Mattermost.Web.get(endpoint, pathing, payload, [], mattermost)
  end

  ####################################################################
  @api_by_name "/api/v3/teams/{{team_id}}/channels/name/{{channel_name}}" # GET
  @doc """
  Get a single channel by team ID and channel name
  """
end
