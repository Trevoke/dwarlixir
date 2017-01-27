defmodule Dwarves.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Dwarves.World, [[]], id: :world), # spawn, move, loc_open?
      worker(Dwarves.Registry, [[]], id: :dwarves),
      worker(Dwarves.Spawn, [], restart: :permanent),
      worker(Dwarves.Timers, [:start_heartbeat], restart: :permanent)
      #worker(Dwarves.Timers, [], restart: permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
