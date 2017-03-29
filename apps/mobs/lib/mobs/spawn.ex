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

  def birth(%{} = options) do
    GenServer.call(:mobs_spawn, {:birth, options})
  end

  def handle_cast({:create_mobs, number_to_spawn}, state) do
    locs =
      World.LocationRegistry
      |> Registry.match(:_, :_)
      |> Enum.map(fn({_pid, val}) -> val end)
    mob_types = [Mobs.Dwarf, Mobs.Bird]
    Enum.each((state.next_id..state.next_id + number_to_spawn), fn id ->
      initial_loc = Enum.random locs
      mob_type = Enum.random mob_types
      give_birth(
        id,
        %{module: mob_type,
        location_id: initial_loc},
        state)
    end)
    {:noreply, %{state | next_id: state.next_id + number_to_spawn + 1}}
  end


  def handle_call({:birth, options}, _from, state) do
    {:ok, _} = give_birth(state.next_id, options, state)
    {:reply, state.next_id, %{state | next_id: state.next_id + 1}}
  end

  defp give_birth(id, %{module: Mobs.Dwarf} = options, state) do
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)
    Mobs.Dwarf.start_link(%Mobs.Dwarf{id: id,
                                      location_id: options.location_id,
                                      gender: gender,
                                      name: Faker.Name.name,
                                      lifespan: lifespan})
  end


  defp give_birth(id, %{module: Mobs.Bird} = options, state) do
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)
    Mobs.Bird.start_link(%Mobs.Bird{id: id,
                                    location_id: options.location_id,
                                    gender: gender,
                                    name: "a bird",
                                    lifespan: lifespan})
  end

  defp give_birth(id, options, state) do
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)
    apply(
      options.module,
      :start_link,
      [struct(options.module, [id: id,
                               location_id: options.location_id,
                               gender: gender,
                               name: Faker.Name.name,
                               lifespan: lifespan])])
  end


  defp random_lifespan(:short), do: 30 + Enum.random(1..20)
  defp random_lifespan(args), do: 1800 + Enum.random(1..7200)
end
