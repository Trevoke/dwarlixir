defmodule World.Pathway do
  defstruct [
    :from_id, :to_id, :name
  ]

  @type t :: %World.Pathway{ from_id: String.t,
                             to_id: String.t,
                             name: String.t }

  use GenServer
  alias World.PathwayRegistry

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(state.from_id, state.to_id))
  end

  defp via_tuple(from_id, to_id) do
    {:via, Registry, {PathwayRegistry, {from_id, to_id}}}
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    tuple = {state.from_id, state.to_id}
    Registry.register(World.Registry, "pathway", tuple)
    new_value = fn(_) -> state.name end
    PathwayRegistry
    |> Registry.update_value(tuple, new_value)
    {:ok, state}
  end

  def exits(location_id) do
    World.Registry
    |> Registry.match("pathway", {location_id, :_})
    |> Enum.flat_map(fn({pid, _}) -> Registry.keys(PathwayRegistry, pid) end)
    |> Enum.map(fn({_from, id}) -> id end)
  end

  def stop(from_id, to_id) do
    GenServer.stop(via_tuple(from_id, to_id))
  end

  def terminate(reason, state) do
    Registry.unregister(PathwayRegistry, {state.from_id, state.to_id})
    reason
  end

end
