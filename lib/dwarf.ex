defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([initial_loc: initial_loc, name: name]) do
    Dwarves.World.add(initial_loc)
    Dwarves.Registry.add(:subject_to_time, [])
    {:ok, %{name: name}}
  end

  def handle_cast({:be}, %{name: name} = state) do
    old_loc = Dwarves.World.current_location
    prop_to_change = Enum.random([:x, :y])
    new_value = :rand.uniform(3) - 2
    new_location = Map.put(old_loc, prop_to_change, old_loc[prop_to_change] + new_value)

    location_available = Dwarves.World.location_available?(new_location)
    log = "#{name} is at #{Kernel.inspect old_loc} and wants to go to #{Kernel.inspect new_location}"
    #IO.puts log
    cond do
      old_loc == new_location ->
        IO.puts "#{log}\n#{name} has decided to stay put."
        {:noreply, state}
      location_available ->
        Dwarves.World.move(new_location)
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

