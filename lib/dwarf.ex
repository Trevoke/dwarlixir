defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{location: initial_loc} = state) do
    Dwarves.World.add(initial_loc)
    Dwarves.Registry.add(:subject_to_time, [])
    {:ok, state}
  end

  def handle_call(:gender, _from, %{gender: gender} = state) do
    {:reply, gender, state}
  end

  # def handle_call(any, from, state) do
  #   IO.inspect any
  #   IO.inspect from
  #   IO.inspect state
  #   {:reply, true, state}
  # end

  def handle_cast({:be}, %{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast({:be}, %{name: name, lifespan: 1} = state) do
    IO.puts "#{name} has just died."
    {:noreply, %{state | lifespan: 0}}
  end

  def handle_cast({:be}, %{
                    name: name,
                    location: current_location,
                    lifespan: lifespan,
                    gender: gender
                  } = state) do
    new_state = %{state | lifespan: lifespan - 1}

    neighbors = sexually_compatible_neighbors(current_location, gender)

    new_location = new_location(current_location)
    location_available = Dwarves.World.location_available?(new_location)

    if location_available do
      Dwarves.World.move(current_location, new_location)
      IO.puts "#{name} is at #{Kernel.inspect current_location} and wants to go to #{Kernel.inspect new_location}"
      {:noreply, %{new_state | location: new_location}}
    else
      {:noreply, new_state}
    end
  end

  def handle_info(msg, state) do
    IO.inspect msg
    {:noreply, state}
  end

  defp sexually_compatible_neighbors(current_location, gender) do
    Dwarves.World.neighbors(current_location)
    |> Enum.map(fn(dwarf) -> GenServer.call(dwarf, :gender) end)
  end

  defp new_location({x, y}) do
    x = x + :rand.uniform(3) - 2
    y = y + :rand.uniform(3) - 2
    {x, y}
  end


end

