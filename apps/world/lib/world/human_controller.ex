defmodule HumanController do
  defstruct [
    :socket, :user_id, :location_id
  ]
  use GenServer

  def start_link(args \\ %HumanController{}) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.user_id))
  end

  defp via_tuple(id) do
    {:via, Registry, {Registry.HumanControllerRegistry, id}}
  end

  def log_in(user_id, password, socket) do
    HumanController.start_link(%HumanController{user_id: user_id, socket: socket})
    {:ok, user_id}
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
        {HumanController, state.user_id},
        public_info(state)
      },
      "seemingly nowhere"
    )
    {:noreply, state}
  end

  def handle_cast({:arrive, info, from_loc}, state) do
    write_line(state.socket,
      "#{info.name} arrived from #{from_loc}.\n")
    {:noreply, state}
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
