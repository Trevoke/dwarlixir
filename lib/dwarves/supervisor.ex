defmodule Dwarves.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Dwarves.Registry, [[name: Dwarves.Registry]], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
