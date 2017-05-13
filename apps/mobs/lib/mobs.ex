defmodule Mobs do
  use GenServer

  def start_link(%{} = state) do
    GenServer.start_link(__MODULE__, Map.put(state, :allow_births, true), name: __MODULE__)
  end

  def init(%{spawn_on_start: false} = state), do: {:ok, state}
  def init(%{spawn_on_start: true} = state) do
    create_mobs(40)
    {:ok, state}
  end

  def deny_births, do: GenServer.cast(__MODULE__, :stop_births)
  def allow_births, do: GenServer.cast(__MODULE__, :allow_births)

  def handle_cast(:stop_births, state) do
    {:ok, %{state | allow_births: false}}
  end

  def handle_cast(:allow_births, state) do
    {:ok, %{state | allow_births: true}}
  end

    def create_mobs(number_of_mobs_to_spawn \\ 40) do
    Task.start(__MODULE__, :generate_mobs, [number_of_mobs_to_spawn])
  end

  def generate_mobs(number_to_spawn) do
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
    GenServer.cast(__MODULE__, {:birth, options})
  end

  def handle_cast({:birth, options}, %{allow_births: allow_births} = state) when allow_births == true do
    {:ok, _} = give_birth(new_id(), options)
    {:noreply, state}
  end
  def handle_cast({:birth, options}, %{allow_births: allow_births} = state) when allow_births == false do
    {:noreply, state}
  end

  defp give_birth(id, %{module: Mobs.Dwarf} = options) do
    import Supervisor.Spec, warn: false

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

    Supervisor.start_child(Mobs.Supervisor, dwarf)
  end


  defp give_birth(id, %{module: Mobs.Bird} = options) do
    import Supervisor.Spec, warn: false

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

    Supervisor.start_child(Mobs.Supervisor, bird)
  end

  defp give_birth(id, options) do
    import Supervisor.Spec, warn: false

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

    Supervisor.start_child(Mobs.Supervisor, mob)
  end

  defp new_id, do: UUID.uuid4(:hex)

  defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)

end
