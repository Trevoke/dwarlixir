defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_mob(args.id))
  end

  defp via_mob(id) do
    {:via, Registry, {Registry.Mobs, id}}
  end

  def init(%{location: initial_loc} = state) do
    Registry.Tick
    |> Registry.register(state.id, nil)
    {:ok, state}
  end

  def handle_cast({:be}, %{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast({:be}, %{name: name, lifespan: 1} = state) do
    IO.puts "#{name} has just died."
    {:noreply, %{state | lifespan: 0}}
  end

  def handle_cast({:be}, %{
                    id: id,
                    name: name,
                    location: location,
                    lifespan: lifespan
                  } = state) do
    new_state = %{state | lifespan: lifespan - 1}

    new_location = new_location(location)

    move_to(id, new_location)

    {:noreply, %{new_state | location: new_location}}

  end

  def handle_info(msg, state) do
    IO.inspect msg
    {:noreply, state}
  end

  defp move_to(id, new_location) do
    Registry.update_value(Registry.Mobs, id, fn(x) -> new_location end)
  end

  defp new_location(location) do
    World.Pathway.exits(location)
    |> Enum.shuffle
    |> List.first
  end

end
