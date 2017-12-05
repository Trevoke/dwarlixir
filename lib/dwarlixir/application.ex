defmodule Dwarlixir.Application do
  @moduledoc false

  alias Dwarlixir.{World, Mobs, Life, Item, Ecosystem, Connections}

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, World.LocationRegistry], id: :location_registry),
      supervisor(Registry, [:unique, World.PathwayRegistry], id: :pathway_registry),
      supervisor(Registry, [:duplicate, World.Registry], id: :world_registry),
      supervisor(World.Supervisor, []),
      worker(World, [%{init: Utils.Config.get(:dwarlixir, :world)[:init]}]),

      supervisor(Registry, [:unique, Mobs.Registry], id: :mobs),
      supervisor(Mobs.Supervisor, [], restart: :permanent),
      worker(Mobs, [%{spawn_on_start: Utils.Config.get(:mobs, :spawn_on_start)}], restart: :permanent),

      worker(Life.Reaper, [], restart: :permanent),
      supervisor(Registry, [:duplicate, Registry.Tick], id: :tick),
      worker(Life.Timers, [%{start_heartbeat: Utils.Config.get(:life, :start_heartbeat)}], restart: :permanent),

      supervisor(Registry, [:unique, Registry.Items], id: :items),

      worker(Ecosystem, [%{}], restart: :permanent),

      supervisor(Task.Supervisor, [[name: Connections.TaskSupervisor]]),
      supervisor(Registry, [:unique, Registry.HumanControllers], id: :human_controllers_registry),
      supervisor(Registry, [:duplicate, Registry.Controllers], id: :controllers_registry),
      worker(Task, [Connections.Tcp, :accept, [4040]])
    ]

    opts = [strategy: :one_for_one, name: Dwarlixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
