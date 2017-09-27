defmodule Connections.Tcp do

  require Logger

  @doc """
  Starts accepting connections on the given `port`.
  """
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(
      Connections.TaskSupervisor,
      fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    write_line(socket, "Choose a username: ")
    {:ok, username} = read_line(socket)
    case Controllers.Human.log_in(username, "password", socket) do
      {:ok, user_id} ->
        Controllers.Human.handle(user_id, {:input, "help"})
        room = World.random_room_id
        Controllers.Human.join_room(user_id, room)
        loop_connection(socket, user_id)
      {:error, :username_taken} ->
        write_line(socket, "Username already online. Try another.\n")
        serve(socket)
      {:error, error} -> write_line(socket, error)
    end
    # TODO disconnect on bad login
    # TODO graceful exit
    # TODO graceful error handling?
  end

  def loop_connection(socket, user_id) do
    case read_line(socket) do
      {:ok, input} ->
        Controllers.Human.handle(user_id, {:input, input})
        loop_connection(socket, user_id)
      {:error, :closed} -> nil
    end
  end

  def read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  def write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end

end
