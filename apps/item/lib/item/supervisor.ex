defmodule Item.Supervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

  def create(:corpse, loc_id, public_info) do
    corpse = worker(
      Item.Corpse,
      [Map.put(public_info, :location_id, loc_id)],
      [id: public_info.id]
    )
    {:ok, pid} = Supervisor.start_child(__MODULE__, corpse)
    World.Location.place_item(loc_id, {Item.Corpse, pid}, public_info)
  end
end
