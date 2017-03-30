defmodule World.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Registry, [:unique, World.LocationRegistry], id: :location_registry),
      supervisor(Registry, [:unique, World.PathwayRegistry], id: :pathway_registry),
      supervisor(World, [%{spawn_locations: Application.get_env(:world, :spawn_locations)}])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: World.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
