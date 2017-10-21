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
      supervisor(Registry, [:duplicate, World.Registry], id: :world_registry),
      supervisor(World.Supervisor, []),
      worker(World, [%{init: Utils.Config.get(:world, :init)}])
    ]

    opts = [strategy: :one_for_one, name: World.Application.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
