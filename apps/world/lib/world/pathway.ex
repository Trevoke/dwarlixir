defmodule World.Pathway do
  defstruct [
    :from_id, :to_id, :name
  ]
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(state.from_id, state.to_id))
  end

  defp via_tuple(from_id, to_id) do
    {:via, Registry, {World.PathwayRegistry, {from_id, to_id}}}
  end

  def init(state) do
    {:ok, state}
  end

  def exits(location_id) do
    World.PathwayRegistry
    |> Registry.match(:exit, {location_id, :_})
    |> Enum.map(fn({_, {_, id}}) -> id end)
  end

end
