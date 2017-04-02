defmodule Mobs.Mixfile do
  use Mix.Project

  def project do
    [app: :mobs,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger],
     mod: {Mobs.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:faker, "~> 0.7.0"},
      {:controllers, in_umbrella: true},
      {:world, in_umbrella: true},
      {:life, in_umbrella: true},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:credo, "~> 0.6.1", only: [:dev], runtime: false},
      {:doc_first_formatter, "~> 0.0.2", only: [:test]},
      { :uuid, "~> 1.1" }
    ]
  end
end
