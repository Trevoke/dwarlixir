defmodule World do
  use Supervisor

  def start_link(opts \\ %{}) do
    Supervisor.start_link(__MODULE__, opts, name: :world)
  end

  def init(%{spawn_locations: false}), do: supervise([], strategy: :one_for_one)

  def init(%{spawn_locations: true}) do
    children =
      map_data()
      |> Enum.map(&(new_loc(&1)))

    supervise(children, strategy: :one_for_one)
  end

  def start_child(opts) do
    Supervisor.start_child(:world, new_loc(opts))
  end

  def new_loc(opts) do
    worker(World.Location, [opts], restart: :transient, id: opts.id)
  end

  defp map_data do
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

  defp location(id, name, desc, pathways) do
    %World.Location{
      id: id,
      name: name,
      description: desc,
      pathways: pathways
    }
  end

  defp partial_pathway(from_id, name) do
    %{from_id: from_id, name: name}
  end
end
