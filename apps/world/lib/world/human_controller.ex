defmodule HumanController do
  defstruct [
    :socket, :user_id
  ]
  use GenServer

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.user_id))
  end

  defp via_tuple(id) do
    {:via, Registry, {Registry.HumanControllerRegistry, id}}
  end

  def log_in(user_id, password, socket) do
    __MODULE__.start_link(%{user_id: user_id, socket: socket})
    {:ok, user_id}
  end

  def handle(user_id, message) do
    IO.inspect via_tuple(user_id)
    IO.inspect message
    IO.inspect Registry.match(Registry.HumanControllerRegistry, :_, :_)
    GenServer.cast(via_tuple(user_id), message)
  end

  def handle_cast({:input, input}, state) do
    IO.puts "test"
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

end
