defmodule World.Pathway do
  defstruct [
    :from_id, :to_id, :name
  ]

  @type t :: %World.Pathway{ from_id: String.t,
                             to_id: String.t,
                             name: String.t }

  use GenServer
  alias World.{Location, PathwayRegistry}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(state.from_id, state.to_id))
  end

  defp via_tuple(from_id, to_id) do
    {:via, Registry, {PathwayRegistry, {from_id, to_id}}}
  end

  def init(state) do
    tuple = {state.from_id, state.to_id}
    new_value = fn(_) -> state.name end
    PathwayRegistry
    |> Registry.update_value(tuple, new_value)
    {:ok, state}
  end

  def move({from, to}, {module, mob_id}, public_info) do
    GenServer.cast(via_tuple(from, to), {:move, {module, mob_id}, public_info})
  end

  def exits(location_id) do
    PathwayRegistry
    |> Registry.match({location_id, :_}, :_)
    |> Enum.flat_map(fn({pid, _}) -> Registry.keys(PathwayRegistry, pid) end)
    |> Enum.map(fn({_from, id}) -> id end)
  end

  def handle_cast(
    {:move, {module, mob_id}, public_info},
    %__MODULE__{from_id: from_id, to_id: to_id, name: exit_name} = state
  ) do
    opposite_path = Registry.lookup(PathwayRegistry, {from_id, to_id})
    incoming_name = case length(opposite_path) do
                      1 -> opposite_path
                      |> List.first
                      |> elem(1)
                      _ -> "seemingly nowhere"
                    end

    tasks = [
      Task.async(fn() -> Location.depart(from_id, {module, mob_id}, public_info, exit_name) end),
      Task.async(fn() -> Location.arrive(to_id, {{module, mob_id}, public_info, incoming_name}) end),
      Task.async(fn() -> Kernel.apply(module, :set_location, [mob_id, to_id]) end)
    ]

    [:ok, :ok, :ok] = Enum.map(tasks, &Task.await/1)

    {:noreply, state}
  end

end
