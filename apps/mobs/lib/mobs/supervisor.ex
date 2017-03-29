defmodule Mobs.Supervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      supervisor(Registry, [:unique, Registry.Mobs], id: :mobs),
      worker(Mobs.Spawn, [
            %{
              lifespan_type: Application.get_env(:mobs, :lifespan),
              spawn_on_start: Application.get_env(:mobs, :spawn_on_start),
              next_id: 1
             }
          ], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end

end
