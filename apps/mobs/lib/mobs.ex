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
    GenServer.call(__MODULE__, {:birth, options})
  end

  def handle_call({:birth, options}, _from, %{allow_births: true} = state) do
    Kernel.apply options.module, :new_life, [options]
    {:reply, :ok, state}
  end
  def handle_call({:birth, _options}, _from, %{allow_births: false} = state) do
    {:reply, {:error, :no_births}, state}
  end

  def handle_cast(:stop_births, state) do
    {:noreply, %{state | allow_births: false}}
  end

  def handle_cast(:allow_births, state) do
    {:noreply, %{state | allow_births: true}}
  end

  # TODO duplicated right now, not sure where to deduplicate it to
  defp new_id, do: UUID.uuid4(:hex)

  defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)

end
