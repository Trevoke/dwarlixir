defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([initial_loc: initial_loc, name: name]) do
    Dwarves.World.add(initial_loc)
    Dwarves.Registry.add(:subject_to_time, [])
    {:ok, %{name: name, location: initial_loc}}
  end

  defp new_location({x, y}) do
    x = x + :rand.uniform(3) - 2
    y = y + :rand.uniform(3) - 2
    {x, y}
  end

  def handle_cast({:be}, %{name: name, location: current_location} = state) do
    new_location = new_location(current_location)

    location_available = Dwarves.World.location_available?(new_location)
    log = "#{name} is at #{Kernel.inspect current_location} and wants to go to #{Kernel.inspect new_location}"
    #IO.puts log
    cond do
      current_location == new_location ->
        IO.puts "#{log}\n#{name} has decided to stay put."
        {:noreply, state}
      location_available ->
        Dwarves.World.move(current_location, new_location)
        IO.puts "#{log}\n#{name} is ambulating."
        {:noreply, state}
      !location_available ->
        IO.puts "#{name} can't move!"
        {:noreply, state}
      true ->
        IO.puts "Something weird happened to #{name}"
        {:noreply, state}
    end
  end

end

