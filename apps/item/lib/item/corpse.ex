defmodule Item.Corpse do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  defp via_tuple(id), do: {:via, Registry, {Registry.Items, id}}

  def init(state) do
    {:ok, Map.put(state, :lifespan, 100)}
  end
end
