defmodule World do
  use Supervisor

  alias World.{Location, Pathway}

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
      location("1", "center", "The center of the universe",
        [
          pathway("2", "brightness"),
          pathway("3", "darkness"),
        ]),
      location("2", "soft", "A room with a soft light",
        [
          pathway("1","center"),
          pathway("3", "darkness (x)"),
        ]),
      location("3", "dark", "Darkness.",
        [
          pathway("1", "center"),
          pathway("2", "brightness")
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

  defp pathway(from_id, name) do
    %Pathway{from_id: from_id, name: name}
  end
end
