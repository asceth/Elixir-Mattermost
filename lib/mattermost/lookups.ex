defmodule Mattermost.Lookups do

  def team_from_channel(channel_id, mattermost) do
    case mattermost.channels[channel_id] do
      %{team_id: team_id} ->
        team_id
      _ ->
        nil
    end
  end



  @doc ~S"""
  Turns a string like `"@USER_NAME"` into the ID that Mattermost understands (`"U…"`).
  """
  def lookup_user_id("@" <> user_name, mattermost) do
    mattermost.users
    |> Map.values
    |> Enum.find(%{ }, fn user -> user.name == user_name end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a string like `"#CHANNEL_NAME"` into the ID that Mattermost understands
  (`"C…"`) if a public channel,
  (`"G…"`) if a group/private channel.
  """
  def lookup_channel_id("#" <> channel_name, mattermost) do
    channel = find_channel_by_name(mattermost.channels, channel_name)
    || find_channel_by_name(mattermost.groups, channel_name)
    || %{}
    Map.get(channel, :id)
  end

  @doc ~S"""
  Turns a Mattermost user ID (`"U…"`) or direct message ID (`"D…"`) into a string in
  the format "@USER_NAME".
  """
  def lookup_user_name(direct_message_id = "D" <> _id, mattermost) do
    lookup_user_name(mattermost.ims[direct_message_id].user, mattermost)
  end
  def lookup_user_name(user_id = "U" <> _id, mattermost) do
    "@" <> mattermost.users[user_id].name
  end

  @doc ~S"""
  Turns a Mattermost channel ID (`"C…"`) into a string in the format "#CHANNEL_NAME".
  """
  def lookup_channel_name(channel_id = "C" <> _id, mattermost) do
    "#" <> mattermost.channels[channel_id].name
  end

  @doc ~S"""
  Turns a Mattermost private channel ID (`"G…"`) into a string in the format "#CHANNEL_NAME".
  """
  def lookup_channel_name(channel_id = "G" <> _id, mattermost) do
    "#" <> mattermost.groups[channel_id].name
  end

  defp find_channel_by_name(nested_map, name) do
    Enum.find_value(nested_map, fn {_id, map} -> if map.name == name, do: map, else: nil end)
  end
end
