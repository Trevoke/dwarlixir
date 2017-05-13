defmodule Mobs.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args), do: supervise([], strategy: :one_for_one)
end
