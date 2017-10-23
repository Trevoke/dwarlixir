defmodule ConnectionsTest do
  use ExUnit.Case
  doctest Connections

  test "A user can log in and quit" do
    loc_id = UUID.uuid4(:hex)
    {:ok, _} = World.Location.start_link(
      %World.Location{
        id: loc_id,
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 1234, [
          :binary, packet: :raw, active: :false
        ])
    {:ok, pkt} = :gen_tcp.recv(socket, 0) # Choose a username
    :ok = :gen_tcp.send(socket, "user1\n")
    :gen_tcp.recv(socket, 0) # Welcome prompt
    :ok = :gen_tcp.send(socket, "look\n")
    {:ok, x} = :gen_tcp.recv(socket, 0)
    room_desc = x |> String.split("\n") |> List.first
    assert room_desc == "what's on the tin"
    :gen_tcp.send(socket, "quit\n")
    {:ok, x} = :gen_tcp.recv(socket, 0)
    assert String.trim(x) == "Goodbye."
  end

end
