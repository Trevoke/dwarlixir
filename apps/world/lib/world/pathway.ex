defmodule World.Pathway do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(%{from: from_id, to: to_id} = state) do
    Registry.register(World.PathwayRegistry, :exit, {from_id, to_id})
    {:ok, state}
  end
end
