defmodule Controllers.Human do
  defstruct [
    :socket, :user_id, :location_id
  ]
  use GenServer

  def start_link(args \\ %__MODULE__{}) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.user_id))
  end

  defp via_tuple(id) do
    {:via, Registry, {Registry.HumanControllers, id}}
  end

  def log_in(user_id, password, socket) do
    with {:ok, pid} <- Controllers.Human.start_link(%__MODULE__{user_id: user_id, socket: socket}) do
      {:ok, user_id}
    else
      {:error, {:already_started, _pid}} -> {:error, :username_taken}
    end
  end

  def handle(user_id, {:input, input}) do
    GenServer.cast(via_tuple(user_id), {:input, String.trim(input)})
  end

  def handle(user_id, message) do
    GenServer.cast(via_tuple(user_id), message)
  end

  def join_room(user_id, loc_id)do
    GenServer.cast(via_tuple(user_id), {:join_room, loc_id})
  end

  def handle_cast({:join_room, loc_id}, state) do
    World.Location.arrive(loc_id,
      {
        {__MODULE__, state.user_id},
        public_info(state),
        "seemingly nowhere"
      }
    )
    {:noreply, %__MODULE__{state | location_id: loc_id}}
  end

  def handle_cast({:arrive, info, from_loc}, state) do
    write_line(state.socket,
      "#{info.name} arrived from #{from_loc}.\n")
    {:noreply, state}
  end

  def handle_cast({:depart, info, to}, state) do
    write_line(state.socket,
    "#{info.name} is leaving #{to}.\n")
    {:noreply, state}
  end

  def handle_cast({:input, "spawn_more"}, state) do
    write_line(state.socket, "Spawning 40 more mobs.\n")
    Mobs.Spawn.create_mobs(40)
    {:noreply, state}
  end

  def handle_cast({:input, "quit"}, state) do
    write_line(state.socket, "Goodbye.\n")
    World.Location.depart(
      state.location_id,
      {
        {__MODULE__, state.user_id},
        state,
        "the real world"
      }
    )
    :gen_tcp.close(state.socket)
    {:stop, :normal, state}
  end

  def handle_cast({:input, "look"}, state) do
    things_seen = World.Location.look(state.location_id)

    text = """
    #{things_seen.description}
    #{Bunt.ANSI.format [:green, read_exits(things_seen.exits)]}
    #{read_entities(things_seen.living_things)}
    #{read_entities(things_seen.items)}
    """
    |> String.trim()
    state.socket
    |> write_line(text <> "\n")
    {:noreply, state}
  end

  defp read_entities(entities) do
    entities
    |> Enum.group_by(&(&1))
    |> Enum.map(fn({k, v}) -> {k, Enum.count(v)} end)
    |> Enum.sort(fn({_n1, c1}, {_n2, c2}) -> c1 > c2 end)
    |> Enum.map(fn
      {name, 1} -> name
      {name, count} -> "#{count} #{name}"
    end)
    |> Enum.join(", ")
  end

  defp read_exits(exits) do
    exit_text =
      exits
      |> Enum.map(fn(x) -> x.name end)
      |> Enum.join(", ")
    "Exits: #{exit_text}."
  end

  def handle_cast({:input, input}, state) do
    write_line(state.socket, "Just received '#{input}'\n")
    {:noreply, state}
  end

  def handle_cast({:death, name}, state) do
    write_line(state.socket, "#{name} has just died.")
    {:noreply, state}
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end

  # TODO do I get a separate process for the user?
  def public_info(state) do
    %{
      gender: :male,
      name: "a user"
    }
  end

end
