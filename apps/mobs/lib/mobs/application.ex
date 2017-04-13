defmodule Mobs.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, Mobs.Registry], id: :mobs),
      # TODO make it a supervisor?
      worker(Mobs.Spawn, [
            %{
              lifespan_type: Application.get_env(:mobs, :lifespan),
              spawn_on_start: Application.get_env(:mobs, :spawn_on_start),
              number_to_spawn: 40
             }
          ], restart: :temporary)
    ]

    opts = [strategy: :one_for_one, name: Mobs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
