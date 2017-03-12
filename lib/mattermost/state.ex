defmodule Mattermost.State do
  @behaviour Access

  def fetch(client, key)
  defdelegate fetch(client, key), to: Map

  def get_and_update(client, key, function)
  defdelegate get_and_update(client, key, function), to: Map

  defstruct [
    :process,
    :url,
    :socket,
    :client,
    :token,
    :me,
    teams: %{},
    channels: %{},
    groups: %{},
    users: %{},
    ims: %{},
  ]

  @doc """
  Pattern matches against messages and returns updated Mattermost state.
  """
  @spec update(Map, Map) :: {Symbol, Map}
  def update(%{event: "add_team", team: team}, mattermost) do
    put_in(mattermost, [:teams, team.id], team)
  end

  def update(%{event: "add_channel", channel: channel}, mattermost) do
    put_in(mattermost, [:channels, channel.id], channel)
  end

  def update(_, mattermost) do
    mattermost
  end
end
