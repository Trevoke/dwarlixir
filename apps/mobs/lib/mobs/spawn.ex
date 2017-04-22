defmodule Mobs.Spawn do
  use GenServer

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, name: :mobs_spawn)
  end

  def init(%{spawn_on_start: false} = state) do
    {:ok, state}
  end

  def init(%{spawn_on_start: true} = state) do
    create_mobs(state.number_to_spawn)
    {:ok, state}
  end

  def create_mobs(x \\ 40) do
    GenServer.cast(:mobs_spawn, {:create_mobs, x})
  end

  def handle_cast({:create_mobs, number_to_spawn}, state) do
    locs =
      World.LocationRegistry
      |> Registry.match(:_, :_)
      |> Enum.map(fn({_pid, val}) -> val end)
    mob_types = [Mobs.Dwarf, Mobs.Bird]
    Enum.each((1..number_to_spawn), fn _n ->
      initial_loc = Enum.random locs
      mob_type = Enum.random mob_types
      birth(%{module: mob_type, location_id: initial_loc})
    end)
    {:stop, :normal, state}
  end


  def birth(options) do
    mob_count = Enum.count World.Location.look(options.location_id).living_things
    if mob_count < 15 do
      {:ok, _} = give_birth(new_id(), options)
    else
      nil
    end
  end

  defp give_birth(id, %{module: Mobs.Dwarf} = options) do
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)
    Mobs.Dwarf.start(%Mobs.Dwarf{id: id,
                                      location_id: options.location_id,
                                      gender: gender,
                                      name: Faker.Name.name,
                                      lifespan: lifespan})
  end


  defp give_birth(id, %{module: Mobs.Bird} = options) do
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = options[:lifespan] || random_lifespan(state.lifespan_type)
    Mobs.Bird.start(%Mobs.Bird{id: id,
                                    location_id: options.location_id,
                                    gender: gender,
                                    name: "a bird",
                                    lifespan: lifespan})
  end

  defp give_birth(id, options) do
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)
    apply(
      options.module,
      :start,
      [struct(options.module, [id: id,
                               location_id: options.location_id,
                               gender: gender,
                               name: Faker.Name.name,
                               lifespan: lifespan])])
  end

  defp new_id, do: UUID.uuid4(:hex)

  defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)
end
