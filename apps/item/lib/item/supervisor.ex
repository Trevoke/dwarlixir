defmodule Item.Supervisor do
  use Supervisor
  import Supervisor.Spec

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

  def create(:corpse, loc_id, public_info) do
    x = worker(Item.Corpse, [public_info], [id: public_info.id])
    {:ok, pid} = Supervisor.start_child(__MODULE__, x)
    World.Location.place(loc_id, pid)
  end
end
