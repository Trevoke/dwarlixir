defmodule Mobs.Application do
  @moduledoc false
  use Application

  def start(_type, [] = _options) do
    import Supervisor.Spec, warn: false
        children = [
      supervisor(Registry, [:unique, Mobs.Registry], id: :mobs),
      supervisor(Mobs.Supervisor, [], restart: :permanent),
      worker(Mobs, [%{spawn_on_start: Utils.Config.get(:mobs, :spawn_on_start)}], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Mobs.Application]
    Supervisor.start_link(children, opts)
  end

end
