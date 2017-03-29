defmodule Mobs.Spawn do
  use GenServer

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, name: :mobs_spawn)
  end

  def init(%{spawn_on_start: false} = state) do
    {:ok, state}
  end

  def init(%{spawn_on_start: true} = state) do
    create_mobs(40)
    {:ok, state}
  end

  def create_mobs(x \\ 40) do
    GenServer.cast(:mobs_spawn, {:create_mobs, x})
  end

  def birth(module: module, location: location_id) do
    GenServer.cast(:mobs_spawn, {:birth, module, location_id})
  end

  def handle_cast({:create_mobs, number_to_spawn}, state) do
    locs =
      World.LocationRegistry
      |> Registry.match(:_, :_)
      |> Enum.map(fn({_pid, val}) -> val end)
    mob_types = [Mobs.Dwarf, Mobs.Bird]
    x = 40
    Enum.each((state.next_id..state.next_id + x), fn id ->
      initial_loc = Enum.random locs
      mob_type = Enum.random mob_types
      give_birth(
        module: mob_type,
        location: initial_loc,
        lifespan_type: state.lifespan_type,
        id: id)
    end)
    {:noreply, %{state | next_id: state.next_id + x + 1}}
  end


  def handle_cast({:birth, module, location_id}, state) do
    give_birth(
      module: module,
      location: location_id,
      lifespan_type: state.lifespan_type,
      id: state.next_id)
    {:noreply, %{state | next_id: state.next_id + 1}}
  end

  defp give_birth(module: Mobs.Dwarf, location: location_id, lifespan_type: lifespan_type, id: id) do
    gender = Enum.random([:male, :female])
    lifespan = random_lifespan(lifespan_type)
    {:ok, _} = Mobs.Dwarf.start_link(%Mobs.Dwarf{id: id,
                                                 location_id: location_id,
                                                 gender: gender,
                                                 name: Faker.Name.name,
                                                 lifespan: lifespan})
  end


  defp give_birth(module: Mobs.Bird, location: location_id, lifespan_type: lifespan_type, id: id) do
    gender = Enum.random([:male, :female])
    lifespan = random_lifespan(lifespan_type)
    {:ok, _} = Mobs.Bird.start_link(%Mobs.Bird{id: id,
                                               location_id: location_id,
                                               gender: gender,
                                               name: "a bird",
                                               lifespan: lifespan})
  end

  defp give_birth(module: module, location: location_id, lifespan_type: lifespan_type, id: id) do
    gender = Enum.random([:male, :female])
    lifespan = random_lifespan(lifespan_type)
    {:ok, _} = apply(
      module,
      :start_link,
      [struct(module, [id: id,
                       location_id: location_id,
                       gender: gender,
                       name: Faker.Name.name,
                       lifespan: lifespan])])
  end


  defp random_lifespan(:short), do: 30 + Enum.random(1..20)
  defp random_lifespan(args), do: 1800 + Enum.random(1..7200)
end
