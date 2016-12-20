defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([initial_values: %{x: x, y: y}, name: name]) do
    {:ok, %{location: %{x: x, y: y}, name: name}}
  end

  def handle_info({:be_dwarfy, world}, %{location: location, name: name} = state) do
    prop_to_change = Enum.random([:x, :y])
    new_value = :rand.uniform(3) - 2
    new_location = Map.put(location, prop_to_change, location[prop_to_change] + new_value)

    location_available = GenServer.call(world, {:location_available?, new_location})
    IO.puts "#{name} is at #{Kernel.inspect location} and wants to go to #{Kernel.inspect new_location}"
    cond do
      location == new_location ->
        IO.inspect "#{name} has decided to stay put."
        {:noreply, state}
      location_available ->
        GenServer.cast(world, {:move, self, new_location})
        IO.inspect "#{name} is ambulating."
        new_state = %{ state | location: new_location}
        {:noreply, new_state}
      !location_available ->
        IO.inspect "#{name} can't move!"
        {:noreply, state}
      true ->
        IO.inspect "Something weird happened to #{name}"
        {:noreply, state}
    end
  end

end

