defmodule Dwarlixir.Item.Supervisor do
  alias Dwarlixir.Item

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
      [id: public_info.id, restart: :transient]
    )
    {:ok, _pid} = Supervisor.start_child(__MODULE__, corpse)
  end

  def create(:egg, loc_id, public_info) do
    egg_id = UUID.uuid4(:hex)
    egg = worker(
      Item.Egg,
      [Map.merge(public_info, %{location_id: loc_id, id: egg_id})],
      [id: egg_id, restart: :transient]
    )
    {:ok, pid} = Supervisor.start_child(__MODULE__, egg)
    {:ok, pid}
  end
end
