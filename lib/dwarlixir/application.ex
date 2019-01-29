defmodule Dwarlixir.Application do
  @moduledoc false

  alias Dwarlixir.{World, Mobs, Life, Item, Ecosystem, Connections}

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Ecstatic.Supervisor,
      {Registry, keys: :unique, name: Registry.HumanControllers},
      {Registry, keys: :unique, name: Registry.Controllers},
      # You know what, the world supervisor needs to do
      # all this, and I need a locationsupervisor
      # that is a dynamic supervisor
      {Registry, keys: :unique, name: World.LocationRegistry},
      {Registry, keys: :unique, name: World.PathwayRegistry},
      {Registry, keys: :duplicate, name: World.Registry},
      World.Supervisor,
      {World, %{init: Utils.Config.get(:dwarlixir, :world)[:init]}},

      {Registry, keys: :unique, name: Mobs.Registry},

      {Connections.Tcp, 4040},

      #supervisor(Mobs.Supervisor, [], restart: :permanent),
      #worker(Mobs, [%{spawn_on_start: Utils.Config.get(:mobs, :spawn_on_start)}], restart: :permanent),

      #worker(Life.Reaper, [], restart: :permanent),
      #supervisor(Registry, [:duplicate, Registry.Tick], id: :tick),
      #worker(Life.Timers, [%{start_heartbeat: Utils.Config.get(:life, :start_heartbeat)}], restart: :permanent),

      #supervisor(Registry, [:unique, Registry.Items], id: :items),

      #worker(Ecosystem, [%{}], restart: :permanent),

    ]

    opts = [strategy: :one_for_one, name: Dwarlixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
