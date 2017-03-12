defmodule Bot do
  use Mattermost
  require Logger


  ####################################################################
  def handle_connect(mattermost, state) do
    {:ok, state}
  end


  ####################################################################
  def handle_event(message = %{event: "hello"}, mattermost, state) do
    teams = case Mattermost.Web.Teams.all(mattermost) do
              {:ok, json} ->
                json
              {:error, reason} ->
                raise reason
            end

    new_mattermost = Map.values(teams)
    |> Enum.reduce(mattermost, fn(team, mattermost) ->
      new_mattermost = Mattermost.State.update(%{event: "add_team", team: team}, mattermost)

      channels = case Mattermost.Web.Channels.all(team.id, mattermost) do
                   {:ok, json} ->
                     json
                   {:error, reason} ->
                     raise reason
                 end

      Enum.reduce(channels, new_mattermost, fn(channel, mattermost) ->
        Mattermost.State.update(%{event: "add_channel", channel: channel}, mattermost)
      end)
    end)

    {:ok, new_mattermost, state}
  end
  def handle_event(message = %{event: "status_change"}, mattermost, state) do
    {:ok, state}
  end
  def handle_event(message = %{event: "channel_viewed"}, mattermost, state) do
    {:ok, state}
  end
  def handle_event(message = %{event: "posted"}, mattermost, state) do
    respond(message, "heard you", mattermost)

    {:ok, state}
  end
  def handle_event(message = %{event: "post_edited"}, mattermost, state) do
    respond(message, "heard your edit", mattermost)

    {:ok, state}
  end
  def handle_event(message, mattermost, state) do
    IO.puts "RECV: #{inspect message, pretty: true}"
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}


  ####################################################################
  def handle_info({:message, team_id, channel_id, text}, mattermost, state) do
    Mattermost.Message.respond(team_id, channel_id, text, mattermost)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}


  ####################################################################
  defp respond(message, text, mattermost) do
    post = JSX.decode!(message.data.post, [{:labels, :atom}])

    if mattermost.me.id != post.user_id do
      Map.get(message.data, :team_id, nil)
      |> Mattermost.Message.respond(post.channel_id, text, mattermost)
    end
  end


  ####################################################################
  defp update_state(mattermost, {:ok, payload}) do
    Mattermost.State.update(payload, mattermost)
  end
  defp update_state(mattermost, _) do
    mattermost
  end


  ####################################################################
  def test do
    Mattermost.Bot.start_link(Bot, [], %{url: "http://localhost:8065", username: "bot", password: "Password1"})
  end
end
