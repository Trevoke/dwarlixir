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
    Controllers.Human.start_link(%__MODULE__{user_id: user_id, socket: socket})
    {:ok, user_id}
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
        public_info(state)
      },
      "seemingly nowhere"
    )
    {:noreply, %__MODULE__{state | location_id: loc_id}}
  end

  def handle_cast({:arrive, info, from_loc}, state) do
    write_line(state.socket,
      "#{info.name} arrived from #{from_loc}.\n")
    {:noreply, state}
  end

  def handle_cast({:input, "quit"}, state) do
    write_line(state.socket, "Goodbye.")
    World.Location.depart(
      state.location_id,
      {__MODULE__, state.user_id},
      "the real world"
    )
    :gen_tcp.close(state.socket)
    {:stop, :normal, state}
  end

  def handle_cast({:input, "look"}, state) do
    things_seen = World.Location.look(state.location_id)

    text = """
    #{things_seen.description}
    #{read_exits(things_seen.exits)}
    #{Enum.join(things_seen.living_things, ", ")}
    #{Enum.join(things_seen.items, ", ")}
    """
    |> String.trim()
    state.socket
    |> write_line(text)
    {:noreply, state}
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

  def handle_cast({:depart, loc_id, mob_id}, state) do
    write_line(
      state.socket,
      "Mob #{mob_id} is leaving #{loc_id} in direction [not implemented]"
    )
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
