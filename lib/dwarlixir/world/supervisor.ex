defmodule Dwarlixir.World.Supervisor do
  alias Dwarlixir.World
  use Supervisor

  def start_link(opts \\ %{}) do
    children = [
      World.Location
    ]

    # TODO this is a simple_one_for_one,
    # was it a mistake to move the registries in here?
    # How about the world?
    Supervisor.start_link(
      children,
      strategy: :simple_one_for_one,
      name: __MODULE__
    )
  end

  def start_child(opts) do
    Supervisor.start_child(__MODULE__, [opts])
  end

  def random_room_id do
    Registry.match(World.Registry, "location", :_)
    |> Enum.map(fn({_, id}) -> id end)
    |> Enum.random
  end

end
