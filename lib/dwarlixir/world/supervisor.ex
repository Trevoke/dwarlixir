defmodule Dwarlixir.World.Supervisor do
  alias Dwarlixir.World
  use Supervisor

  def start_link(opts \\ %{}) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children = [
      World.Location
    ]

    # TODO this is a simple_one_for_one,
    # was it a mistake to move the registries in here?
    # How about the world?
    Supervisor.init(
      children,
      strategy: :simple_one_for_one
    )
    # children = []
    # supervise(children, strategy: :one_for_one)
  end

  def start_child(opts) do
    Supervisor.start_child(__MODULE__, [opts])
  end

end
