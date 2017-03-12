defmodule Mattermost.Mixfile do
  use Mix.Project

  def project do
    [app: :mattermost,
     version: "0.1.0",
     elixir: "~> 1.4",
     name: "Mattermost",
     deps: deps(),
     docs: docs(),
     source_url: "https://github.com/asceth/elixir-mattermost",
     description: "A Mattermost Real Time Messaging API client.",
     package: package()]
  end

  def application do
    [applications: [:logger, :httpoison, :hackney, :exjsx, :crypto, :websocket_client]]
  end

  defp deps do
    [{:httpoison, "~> 0.11"},
     {:exjsx, "~> 3.2.0"},
     {:websocket_client, "~> 1.2.1"},
     {:mustache, "~> 0.3.1"},
     {:earmark, "~> 0.2.0", only: :dev},
     {:ex_doc, "~> 0.12", only: :dev}]
  end

  def docs do
    [{:main, Slack}]
  end

  defp package do
    %{maintainers: ["John Long"],
      licenses: ["MIT"],
      links: %{
        "Github": "https://github.com/asceth/elixir-mattermost",
        "Documentation": "http://hexdocs.pm/mattermost/"}}
  end
end
