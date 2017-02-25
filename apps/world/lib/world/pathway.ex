defmodule World.Pathway do
  defstruct [
    :from_id, :to_id, :name
  ]

  @type t :: %World.Pathway{ from_id: String.t,
                       to_id: String.t,
                       name: String.t }
  use GenServer
  alias World.{Location, LocationRegistry, PathwayRegistry}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(state.from_id, state.to_id))
  end

  defp via_tuple(from_id, to_id) do
    {:via, Registry, {PathwayRegistry, {from_id, to_id}}}
  end

  def init(state) do
    tuple = {state.from_id, state.to_id}
    new_value = fn(_) -> tuple end
    PathwayRegistry
    |> Registry.update_value(tuple, new_value)
    {:ok, state}
  end

  def move({from, to}, mob_id) do
    GenServer.cast(via_tuple(from, to), {:move, mob_id})
  end

  def exits(location_id) do
    PathwayRegistry
    |> Registry.match({location_id, :_}, :_)
    |> Enum.map(fn({pid, tuple}) -> tuple end)
    |> Enum.map(fn({_, id}) -> id end)
  end

  def handle_cast({:move, mob_id}, state) do
    :ok = Location.depart(state.from_id, mob_id)
    :ok = Location.arrive(state.to_id, mob_id)
    {:noreply, state}
  end

end
