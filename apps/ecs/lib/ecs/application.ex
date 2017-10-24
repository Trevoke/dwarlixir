defmodule Ecs.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Supervisor.child_spec({
        Registry,
        keys: :duplicate,
        name: Ecs.Registry,
        partitions: System.schedulers_online()
      }, id: Ecs.Registry),
      Supervisor.child_spec({
        Registry,
        keys: :unique,
        name: Ecs.ComponentRegistry,
        partitions: System.schedulers_online()
      }, id: Ecs.ComponentRegistry)
    ]

    opts = [strategy: :one_for_one, name: Ecs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
