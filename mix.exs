defmodule Elixirding.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixirding,
      version: "0.1.0",
      elixir: "~> 1.5-dev",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [
        :plug,
        :cowboy,
        :httpotion,
        :json,
        :logger,
      ],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:plug, "~> 1.3.4"},
      {:cowboy, "~> 1.1.2"},
      {:httpotion, "~> 3.0.2"},
      {:json, "~> 1.0"},
    ]
  end
end
