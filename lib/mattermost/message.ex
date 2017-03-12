defmodule Mattermost.Message do

  @doc """
  Passes back a map containing necessary message attributes.  Will attempt
  to lookup a team_id from the channel_id if team_id is missing.
  """
  def respond(nil, channel_id, text, mattermost) do
    Mattermost.Lookups.team_from_channel(channel_id, mattermost)
    |> respond(channel_id, text, mattermost)
  end
  def respond(team_id, channel_id, text, mattermost) do
    Mattermost.Web.Posts.create(team_id, channel_id, text, mattermost)
  end
end
