defmodule Dwarf do
  defstruct [
    :id, :location_id, :lifespan,
    :gender, :controller,
    name: ""
  ]
  use GenServer

  alias World.Location

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_mob(args.id))
  end

  defp via_mob(id), do: {:via, Registry, {Registry.Mobs, id}}

  def init(%Dwarf{location_id: location_id} = state) do
    Location.track(location_id, state.id)

    {:ok, pid} = GenericMobController.start_link(%{id: state.id, timer_ref: nil})
    {:ok, %{state | controller: pid}}
  end

  def tick(mob_id) do
    GenServer.cast(via_mob(mob_id), :tick)
  end

  def handle_cast(:tick, %Dwarf{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast(:tick, %Dwarf{name: name, lifespan: 1} = state) do
    IO.puts "#{name} has died, this should be an event"
    {:noreply, %{state | lifespan: 0}}
  end

  def handle_cast(:tick, %Dwarf{
        id: id,
        name: name,
        location_id: location_id,
        lifespan: lifespan
                  } = state) do

    new_location = new_location(location_id)
    move_to(new_location, state)

    {:noreply,
     %{state | location_id: new_location, lifespan: lifespan - 1}
    }
  end

  defp move_to(new_location_id, state) do
    World.Location.move(state.location_id, state.id, new_location_id)
  end

  defp new_location(location) do
    World.Pathway.exits(location)
    |> Enum.shuffle
    |> List.first
  end

end
