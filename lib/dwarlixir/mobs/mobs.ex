defmodule Dwarlixir.Mobs do
  @moduledoc """
  ECS-based mob spawning and management system.

  This module handles spawning mobs (Birds, Dwarves) into the world
  using the Ecstatic ECS framework.
  """

  alias Dwarlixir.{World, Components, Entities}
  alias Dwarlixir.Components, as: C
  use GenServer

  def start_link(%{} = state) do
    GenServer.start_link(__MODULE__, Map.put(state, :allow_births, true), name: __MODULE__)
  end

  def init(%{spawn_on_start: false} = state), do: {:ok, state}
  def init(%{spawn_on_start: true} = state) do
    create_mobs(40)
    {:ok, state}
  end

  @doc """
  Deny new births (used by Ecosystem for population control)
  """
  def deny_births, do: GenServer.cast(__MODULE__, :stop_births)

  @doc """
  Allow new births
  """
  def allow_births, do: GenServer.cast(__MODULE__, :allow_births)

  @doc """
  Spawn a number of mobs into random locations
  """
  def create_mobs(number_of_mobs_to_spawn \\ 40) do
    Task.start(__MODULE__, :generate_mobs, [number_of_mobs_to_spawn])
  end

  @doc """
  Generate mobs by spawning them as ECS entities
  """
  def generate_mobs(number_to_spawn) do
    locs = get_random_locations()
    mob_types = [Entities.Bird, Entities.Dwarf]

    Enum.each(1..number_to_spawn, fn _n ->
      initial_loc = Enum.random(locs)
      mob_type = Enum.random(mob_types)
      birth(%{entity_type: mob_type, location_id: initial_loc})
    end)
  end

  @doc """
  Birth a new mob entity
  """
  def birth(options) do
    GenServer.call(__MODULE__, {:birth, options})
  end

  def handle_call({:birth, options}, _from, %{allow_births: true} = state) do
    entity = spawn_mob_entity(options)
    {:reply, {:ok, entity}, state}
  end

  def handle_call({:birth, _options}, _from, %{allow_births: false} = state) do
    {:reply, {:error, :births_denied}, state}
  end

  def handle_cast(:stop_births, state) do
    {:noreply, %{state | allow_births: false}}
  end

  def handle_cast(:allow_births, state) do
    {:noreply, %{state | allow_births: true}}
  end

  # Private functions

  defp spawn_mob_entity(%{entity_type: entity_type, location_id: loc_id} = _options) do
    # Get lifespan configuration
    lifespan_type = Application.get_env(:mobs, :lifespan, :long)
    life_expectancy = random_lifespan(lifespan_type)

    # Determine entity name based on type
    entity_name = case entity_type do
      Entities.Bird -> "bird"
      Entities.Dwarf -> "dwarf"
      _ -> "creature"
    end

    # Create Age component with random life expectancy
    age_component = struct(C.Age, %{
      state: %{age: 0, life_expectancy: life_expectancy}
    })

    # Create Mortal component
    mortal_component = struct(C.Mortal, %{state: %{mortal: true}})

    # Create Location component
    location_component = struct(C.Location, %{
      state: %{location_id: loc_id}
    })

    # Create EntityType component
    entity_type_component = struct(C.EntityType, %{
      state: %{type: entity_type, name: entity_name}
    })

    # Create the entity with all components
    components = [age_component, mortal_component, location_component, entity_type_component]

    entity = Entity.new(components)

    # TODO: Register entity in Mobs.Registry
    # TODO: Notify location of new entity arrival via World.Location.arrive

    entity
  end

  defp get_random_locations do
    World.Registry
    |> Registry.match(:_, :_)
    |> Enum.filter(fn {_pid, {key, _val}} -> key == "location" end)
    |> Enum.map(fn {_pid, {_key, val}} -> val end)
    |> Enum.take(100)  # Limit to 100 random locations for performance
  end

  defp random_lifespan(:short), do: 30 + Enum.random(1..20)
  defp random_lifespan(_args), do: 180 + Enum.random(1..720)
end
