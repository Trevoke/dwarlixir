defmodule Dwarf do
  # TODO don't forget the controller
  defstruct [
    :id, :location_id, :lifespan,
    name: ""
  ]
  use GenServer

  alias World.Location

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_mob(args.id))
  end

  defp via_mob(id) do
    {:via, Registry, {Registry.Mobs, id}}
  end

  def init(%Dwarf{location_id: location_id} = state) do
    Location.track(location_id, state.id)

    tick = fn(pid) -> GenServer.cast(via_mob(state.id), {:tick}) end
    {:ok, pid} = Petick.start(interval: 1000, callback: tick)

    Registry.register(Registry.Tick, state.id, pid) # last number is timer's pid
    {:ok, state}
  end

  def handle_cast({:tick}, %Dwarf{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast({:tick}, %Dwarf{name: name, lifespan: 1} = state) do
    IO.puts "#{name} has just died."
    {:noreply, %{state | lifespan: 0}}
  end

  def handle_cast({:tick}, %Dwarf{
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

  def handle_info(msg, state) do
    IO.inspect msg
    {:noreply, state}
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
