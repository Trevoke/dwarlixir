defmodule GenericMobController do
  use GenServer

  @tick 1000

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(:tick, state) do
    # TODO more generic than "Dwarf" ?
    Mobs.Dwarf.tick(state.id)
    {:noreply, state}
  end
end
