defmodule Life.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Life.Reaper, [], restart: :permanent),
      supervisor(Registry, [:duplicate, Registry.Tick], id: :tick),
      worker(Life.Timers, [%{start_heartbeat: Application.get_env(:life, :start_heartbeat)}], restart: :permanent)
      # worker(Life.Timers, [[]], restart: :permanent)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Life.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
