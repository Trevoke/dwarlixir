defmodule Item.Corpse do
  use GenServer

  import Item

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  def via_tuple(id), do: {:via, Registry, {Registry.Items, id}}

  def init(state) do
    Registry.register(Registry.Tick, :subject_to_time, nil)
    {:ok, Map.put(state, :lifespan, 100)}
  end

  def handle_cast(:tick, %{lifespan: 0} = state) do
    # TODO send a message?
    GenServer.stop(self())
    {:noreply, state}
  end

  def handle_cast(:tick, %{lifespan: lifespan} = state) do
    {:noreply, %{state | lifespan: lifespan - 1}}
  end

  def terminate(reason, state) do
    World.Location.remove_item(state.location_id, {__MODULE__, state.id})
    Registry.unregister(Registry.Tick, self())
    Registry.unregister(Registry.Items, state.id)
    reason
  end
end
