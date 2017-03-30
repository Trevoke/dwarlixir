defmodule Mobs.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
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

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mobs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
