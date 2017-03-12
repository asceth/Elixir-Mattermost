defmodule Mattermost.Web.Teams do

  ####################################################################
  @api_by_name "/api/v3/teams/name/{{team_name}}" # GET
  @doc """
  Get team object by name
  """
  def by_name(team_name, mattermost) do
    endpoint = mattermost.url <> @api_by_name
    pathing = %{team_name: team_name}
    payload = %{}

    Mattermost.Web.get(endpoint, pathing, payload, [], mattermost)
  end


  ####################################################################
  @api_all "/api/v3/teams/all" # GET
  @doc """
  All teams the mattermost connection has access to
  """
  def all(mattermost) do
    endpoint = mattermost.url <> @api_all
    pathing = %{}
    payload = %{}

    Mattermost.Web.get(endpoint, pathing, payload, [], mattermost)
  end


  ####################################################################
  @api_member_of "/api/v3/teams/members" # GET
  @doc """
  All teams the mattermost connection is a member of
  """
  def member_of(mattermost) do
    endpoint = mattermost.url <> @api_member_of
    pathing = %{}
    payload = %{}

    Mattermost.Web.get(endpoint, pathing, payload, [], mattermost)
  end


  ####################################################################
  @api_unread "/api/v3/teams/teams/unread" # GET
  @doc """
  Get the count for unread messages and mentions in the teams the
  user is a member of
  """
  def unread(mattermost) do
    endpoint = mattermost.url <> @api_by_name
    pathing = %{}
    payload = %{}

    Mattermost.Web.get(endpoint, pathing, payload, [], mattermost)
  end

  @api_members "/api/v3/teams/{team_id}/members/{offset}/{limit}"
  @api_member "/api/v3/teams/{team_id}/members/{user_id}"
  @api_me "/api/v3/teams/{team_id}/me"
  @api_stats "/api/v3/teams/{team_id}/stats"
  @api_slash_commands "/api/v3/teams/{team_id}/commands/list_team_commands"

  # POST
  @api_create "/api/v3/teams/create"
  @api_update "/api/v3/teams/{team_id}/update"

  @api_members_by_id "/api/v3/teams/{team_id}/members/ids"

  @api_add_user "/api/v3/teams/{team_id}/add_user_to_team"
  @api_remove_user "/api/v3/teams/{team_id}/remove_user_from_team"
end
