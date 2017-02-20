defmodule Dwarf do
  # TODO don't forget the controller
  defstruct [
    :id, :location_id, :lifespan,
    name: ""
  ]
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_mob(args.id))
  end

  defp via_mob(id) do
    {:via, Registry, {Registry.Mobs, id}}
  end

  def init(%Dwarf{location_id: location_id} = state) do
    Registry.Tick
    |> Registry.register(state.id, nil)
    move_to(location_id, state)
    {:ok, state}
  end

  def handle_cast({:be}, %Dwarf{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast({:be}, %Dwarf{name: name, lifespan: 1} = state) do
    IO.puts "#{name} has just died."
    {:noreply, %{state | lifespan: 0}}
  end

  def handle_cast({:be}, %Dwarf{
                    id: id,
                    name: name,
                    location_id: location_id,
                    lifespan: lifespan
                  } = state) do

    new_location = new_location(location_id)
    move_to(id, new_location)

    {:noreply,
     %{state | location: new_location, lifespan: lifespan - 1}
    }
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
