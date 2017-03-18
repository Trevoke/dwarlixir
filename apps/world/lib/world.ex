defmodule World do
  use Supervisor

  alias World.Location

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children =
      map_data()
      |> Enum.map(fn(location) -> worker(Location, [location], id: location.id) end)

    supervise(children, strategy: :one_for_one)
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
        ])
    ]
  end

  defp location(id, name, desc, pathways) do
    %Location{
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
