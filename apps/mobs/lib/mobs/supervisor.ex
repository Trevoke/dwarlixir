defmodule Mobs.Supervisor do
  use Supervisor

  def start_link(%{number_to_spawn: number_to_spawn} = state) do
    create_mobs(number_to_spawn)
    Supervisor.start_link([], Map.to_list(state))
  end

  def start_link(%{} = state) do
    Supervisor.start_link([], Map.to_list(state))
  end

  def create_mobs(number_of_mobs_to_spawn \\ 40) do
    Task.start(__MODULE__, :spawn_mobs, [number_of_mobs_to_spawn])
  end

  def spawn_mobs(number_to_spawn) do
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
  end


  def birth(options) do
    with %{active: mob_count} <- Supervisor.count_children(__MODULE__),
         true <- mob_count < 100 do
      {:ok, _} = give_birth(new_id(), options)
    end
  end

  defp give_birth(id, %{module: Mobs.Dwarf} = options) do
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)

    dwarf = worker(
      Mobs.Dwarf,
      [%Mobs.Dwarf{id: id,
                   location_id: options.location_id,
                   gender: gender,
                   name: Faker.Name.name,
                   lifespan: lifespan}],
      [id: id]
    )

    Supervisor.start_child(__MODULE__, dwarf)
  end


  defp give_birth(id, %{module: Mobs.Bird} = options) do
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = options[:lifespan] || random_lifespan(state.lifespan_type)

    bird = worker(
      Mobs.Bird,
      [%Mobs.Bird{id: id,
                  location_id: options.location_id,
                  gender: gender,
                  name: "a bird",
                  lifespan: lifespan}],
      [id: id]
    )

    Supervisor.start_child(__MODULE__, bird)
  end

  defp give_birth(id, options) do
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)

    mob = worker(
      options.module,
      [struct(options.module, [id: id,
                               location_id: options.location_id,
                               gender: gender,
                               name: Faker.Name.name,
                               lifespan: lifespan])],
      [id: id]
    )

    Supervisor.start_child(__MODULE__, mob)
  end

  defp new_id, do: UUID.uuid4(:hex)

  defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)
end
