defmodule Mobs.Application do
  @moduledoc false
  use Application

  def start(_type, [%{spawn_on_start: true}]) do
    import Supervisor.Spec, warn: false
        children = [
      supervisor(Registry, [:unique, Mobs.Registry], id: :mobs),
      supervisor(
        Mobs.Supervisor,
        [
          %{number_to_spawn: 40,
            strategy: :one_for_one,
            name: Mobs.Supervisor}
        ],
        restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Mobs.Application]
    Supervisor.start_link(children, opts)
  end

  def start(_type, [%{spawn_on_start: false}]) do
    import Supervisor.Spec, warn: false
        children = [
      supervisor(Registry, [:unique, Mobs.Registry], id: :mobs),
      supervisor(
        Mobs.Supervisor,
        [%{strategy: :one_for_one, name: Mobs.Supervisor}],
        restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Mobs.Application]
    Supervisor.start_link(children, opts)
  end

end
