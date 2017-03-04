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
    {:noreply, %Dwarf{state | lifespan: 0}}
  end

  def handle_cast(:tick, %Dwarf{lifespan: lifespan} = state) do

    new_state = case Enum.random(1..100) do
                  x when x < 90 -> move_to_random_location(state)
                  _ -> try_to_flirt(state)
                end

    {:noreply, %Dwarf{new_state | lifespan: lifespan - 1}}
  end

  defp move_to_random_location(state) do
    new_loc = Enum.random World.Pathway.exits(state.location_id)
    World.Location.move(state.location_id, state.id, new_loc)
    %Dwarf{state | location_id: new_loc}
  end

  defp try_to_flirt(state) do
    state
  end

end
