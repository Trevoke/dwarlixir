defmodule Dwarlixir.Item.Egg do
  alias Dwarlixir.Item
  alias Dwarlixir.World

  use GenServer

  def via_tuple(id), do: {:via, Registry, {Registry.Items, id}}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  def init(state) do
    state =
      state
      |> Map.put(:name, "egg")
      |> Map.put(:lifespan, 30)
    Registry.register(Registry.Tick, :subject_to_time, nil)
    World.Location.place_item(state.location_id, {__MODULE__, state.id}, state)
    {:ok, state}
  end

  def handle_cast(:tick, %{lifespan: 0} = state) do
    World.Location.remove_item(state.location_id, {__MODULE__, state.id})
    birth =
      Task.async(
        state.module,
        :birth,
        [state]
      )

    Task.yield(birth, 50) || Task.shutdown(birth)

    # TODO send a message?
    {:stop, :normal, state}
  end

  def handle_cast(:tick, %{lifespan: lifespan} = state) do
    {:noreply, %{state | lifespan: lifespan - 1}}
  end

  def terminate(reason, state) do
    Registry.unregister(Registry.Tick, self())
    Registry.unregister(Registry.Items, state.id)
    reason
  end
end
