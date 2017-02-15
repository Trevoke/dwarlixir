defmodule World do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = map_data()
    |> Enum.map(fn(room) -> worker(World.Location, [room], id: room.room_id) end)

    supervise(children, strategy: :one_for_one)
  end

  defp map_data do
    [
      room(1, [2, 3], "The center of the universe"),
      room(2, [1, 3], "A room with a soft light"),
      room(3, [1, 2], "Darkness.")
    ]
  end

  defp room(id, ids_of_rooms_linking_to_this_one, desc) do
    %{
      room_id: id,
      description: desc,
      incoming_pathways: ids_of_rooms_linking_to_this_one
    }
  end
end
