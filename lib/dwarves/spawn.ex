defmodule Dwarves.Spawn do
  use GenServer

  def start_link() do
    # 1. Pass the name to GenServer's init
    GenServer.start_link(__MODULE__, Dwarves.Spawn, name: :dwarves_spawn)
  end

  ## Server callbacks

  def init(_args) do
    Enum.each((1..40), fn x ->
      initial_loc = %{x: x, y: x}
      {:ok, _} = Dwarf.start_link([initial_loc: initial_loc, name: Faker.Name.name])
    end)
    {:ok, %{}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
