defmodule Dwarves.Spawn do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: :dwarves_spawn)
  end

  def init(args) do
    x = 300
    Enum.each((1..x), fn id ->
      initial_loc = Enum.random ["1", "2", "3"]
      give_birth(location: initial_loc, lifespan_type: args, id: id)
    end)
    {:ok, %{lifespan_type: args, next_id: x + 1}}
  end

  def birth(location: location_id) do
    GenServer.cast(:dwarves_spawn, {:birth, location_id})
  end

  def handle_cast({:birth, location_id}, state) do
    give_birth(location: location_id, lifespan_type: state.lifespan_type, id: state.next_id)
    {:noreply, %{state | next_id: state.next_id + 1}}
  end

  # def handle_cast({:birth, %{id: id, location: location, lifespan: lifespan_type}}, state) do
  #   birth(id, location, lifespan: lifespan_type)
  #   {:noreply, state}
  # end

  defp give_birth(location: location_id, lifespan_type: lifespan_type, id: id) do
    gender = Enum.random([:male, :female])
    lifespan = random_lifespan(lifespan_type)
    {:ok, _} = Dwarf.start_link(
      %Dwarf{id: id,
             location_id: location_id,
             gender: gender,
             name: Faker.Name.name,
             lifespan: lifespan})
  end

  defp random_lifespan({:short_lifespan}), do: 30 + Enum.random(1..20)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)
end
