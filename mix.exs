defmodule BSB.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bsb,
      version: "2018.1229.2",
      elixir: "~> 1.7.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # # Type `mix help compile.app` for more information.
  # def application do
  #   [
  #     mod: {BSB, []},
  #     applications: [
  #       :phoenix,
  #       :phoenix_pubsub,
  #       :phoenix_html,
  #       :logger,
  #       :gettext,
  #       :phoenix_ecto,
  #       :postgrex,
  #       :httpoison,
  #       :timex,
  #       :quantum,
  #       :feeder_ex
  #     ],
  #     extra_applications: [:elixir_feed_parser]
  #   ]
  # end

  def application do
    [
      mod: {BSB, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:httpoison, "~> 1.0"},
      {:elixir_feed_parser, "~> 2.0"},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:timex, "~> 3.1"},
      {:quantum, "~> 2.2"},
      {:distillery, "~> 2.0", runtime: false},
      {:bootleg, "~> 0.10", runtime: false},
      {:bootleg_phoenix, "~> 0.2", runtime: false},
      {:feeder_ex, ">= 1.1.0"},
      {:plug_cowboy, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
