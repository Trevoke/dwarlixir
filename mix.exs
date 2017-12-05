defmodule Dwarlixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :dwarlixir,
      version: "0.0.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :runtime_tools],
     mod: {Dwarlixir.Application, []}]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:credo, "~> 0.8.8", only: [:dev], runtime: false},
      {:distillery, "~> 1.0", runtime: false},
      {:ecstatic, path: "~/src/projects/ecstatic"},
      {:logger_file_backend, "~> 0.0.9"},
      {:faker, "~> 0.9.0"},
      {:uuid, "~> 1.1"},
      {:petick, "~> 0.0.1"},
      {:table_rex, "~> 0.10.0"},
      {:bunt, "~> 0.2.0"}
    ]
  end
end
