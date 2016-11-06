defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([initial_values: %{x: x, y: y}]) do
    {:ok, %{x: x, y: y}}
  end

  def handle_info({:be_dwarfy, world}, state) do
    prop_to_change = Enum.random([:x, :y])
    new_value = :rand.uniform(3) - 2
    new_state = Map.put(state, prop_to_change, state[prop_to_change] + new_value)
    location_available = GenServer.call(world, {:location_available?, new_state})
    if(location_available) do
      GenServer.cast(world, {:move, self, new_state})
      IO.inspect "Hey, #{Kernel.inspect(self)} can move!"
      {:noreply, new_state}
    else
      IO.inspect "Urgh, #{Kernel.inspect(self)} can't move!"
      {:noreply, state}
    end
  end

end

