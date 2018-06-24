defmodule Manga.MixProject do
  use Mix.Project

  def project do
    [
      app: :manga,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def escript do
    [{:main_module, Manga}]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Manga.Application, []},
      extra_applications: [:logger, :eex, :tabula]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:httpotion, "~> 3.1"},
      {:floki, "~> 0.20.2"},
      {:download, github: "Hentioe/download.ex", tag: "0.0.5"},
      {:uuid, "~> 1.1"},
      {:progress_bar, "~> 1.6"},
      {:tabula, "~> 2.2"},
      {:elixir_mbcs, github: "Hentioe/elixir-mbcs", tag: "0.1.4"}
    ]
  end
end
