defmodule Dwarves.Supervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      supervisor(Registry, [:unique, Registry.Mobs], id: :mobs),
      supervisor(Registry, [:unique, Registry.Tick], id: :tick),
      worker(Dwarves.Spawn, [{:short_lifespan}], restart: :permanent),
      #worker(Dwarves.Timers, [{:start_heartbeat}], restart: :permanent)
#       worker(Dwarves.Timers, [[]], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end

end
