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
        IO.inspect new_state
    {:noreply, new_state}
  end

end

