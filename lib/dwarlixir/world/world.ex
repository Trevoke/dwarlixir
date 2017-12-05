defmodule Dwarlixir.World do
  alias Dwarlixir.World
  @type t :: [World.Location.t]
  use GenServer

  @ets_name :world
  @world_map_key :world_map

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(%{init: false}) do
    :ets.new(@ets_name, [:set, :named_table, :protected])
    common_init([])
  end

  def init(%{init: :simple}) do
    :ets.new(@ets_name, [:set, :named_table, :protected])
    children = map_data_old()
    common_init(children)
  end
  def init(%{init: :new}) do
    :ets.new(@ets_name, [:set, :named_table, :protected])
    children = map_data()
    common_init(children)
  end
  def init(%{init: world}) do
    {:ok, @ets_name} = :ets.file2tab(@ets_name)
    [{{:world_map, _world}, children}] = :ets.lookup(@ets_name, {@world_map_key, world})
    common_init(children)
  end

  def save_world do
    GenServer.call(__MODULE__, :save_world)
  end

  defp common_init(children) do
    Enum.each(children, &World.Supervisor.start_child/1)
    {:ok, %{}}
  end

  def handle_call(:save_world, _from, state) do
    world_identifier = UUID.uuid4(:hex)
    world =
      Supervisor.which_children(World.Supervisor)
      |> Enum.map(fn({_id, pid, _type, _module}) -> pid end)
      |> Enum.map(&Task.async(fn() -> GenServer.call(&1, :location_data) end))
      |> Enum.map(&Task.await/1)
    :ets.insert(@ets_name, {{@world_map_key, world_identifier}, world})
    :ets.tab2file(@ets_name, @ets_name)
    {:reply, world_identifier, state}
  end

  @spec map_data() :: World.t
  def map_data, do: World.Generator.call

  @spec map_data_old() :: World.t
  def map_data_old do
    [
      location("1", "The Broken Drum", "A tired bar that has seen too many fights",
        [
          partial_pathway("2", "upstairs"),
          partial_pathway("3", "out"),
        ]),
      location("2", "A quiet room", "This room is above the main room of the Broken Drum, and surprisingly all the noise dies down up here",
        [
          partial_pathway("1","down"),
        ]),
      location("3", "outside", "This is the street outside the Broken Drum",
        [
          partial_pathway("1", "drum"),
          partial_pathway("4", "east")
        ]),
      location("4", "a busy street", "The Broken Drum is West of here.",
        [
          partial_pathway("3", "west"),
          partial_pathway("5", "north")
        ]),
      location("5", "a dark alley", "It is dark and you are likely to be eaten by a grue.",
        [
          partial_pathway("4", "south")
        ])
    ]
  end

  def location(id, name, desc, pathways) do
    %World.Location{
      id: id,
      name: name,
      description: desc,
      pathways: pathways
    }
  end

  def partial_pathway(from_id, name) do
    %{from_id: from_id, name: name}
  end
end
