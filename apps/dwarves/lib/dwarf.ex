defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{location: initial_loc} = state) do
    Dwarves.Registry.set_loc(initial_loc)
    Dwarves.Registry.add(:subject_to_time, [])
    {:ok, state}
  end

  def handle_call(:gender, _from, %{gender: gender} = state) do
    {:reply, gender, state}
  end

  def handle_cast({:be}, %{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast({:be}, %{name: name, lifespan: 1} = state) do
    IO.puts "#{name} has just died."
    {:noreply, %{state | lifespan: 0}}
  end

  def handle_cast({:be}, %{
                    name: name,
                    location: location,
                    lifespan: lifespan,
                    gender: gender
                  } = state) do
    new_state = %{state | lifespan: lifespan - 1}

#    neighbors = sexually_compatible_neighbors(location, gender)

    new_location = new_location(location)

    Dwarves.Registry.set_loc(location, new_location)

    {:noreply, %{new_state | location: new_location}}

  end

  def handle_info(msg, state) do
    IO.inspect msg
    {:noreply, state}
  end

  # defp sexually_compatible_neighbors(current_location, gender) do
  #   Dwarves.World.neighbors(current_location)
  #   |> Enum.map(fn(dwarf) -> GenServer.call(dwarf, :gender) end)
  # end

  defp new_location(location) do
    World.PathwayRegistry
      |> Registry.match(:exit, %{from: location, to: :_})
      |> Enum.map(fn({_, %{to: id}}) -> id end)
      |> Enum.shuffle
      |> List.first
  end

end
