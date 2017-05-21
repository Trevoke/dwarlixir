defmodule World.LocationTest do
  use ExUnit.Case
  doctest World.Location

  describe "When a location crashes" do

    def kill_loc(id), do: Process.exit(GenServer.whereis(loc_pid(id)), :kill)
    def loc_pid(id), do: World.Location.via_tuple(id)

    test "kills and respawns its own pathways" do
      loc_id1 = UUID.uuid4(:hex)
      loc_id2 = UUID.uuid4(:hex)
      map = [
        World.location(
          loc_id1, "one", "one", [World.partial_pathway(loc_id2, "two_two")]),
        World.location(
          loc_id2, "two", "two", [World.partial_pathway(loc_id1, "one_one")])
      ]
      Enum.each(map, fn(loc) -> World.start_child(loc) end)
      kill_loc(loc_id1)
      Process.sleep 20
      kill_loc(loc_id2)
      Process.sleep 20
      assert World.Location.look(loc_id1).exits == [%{from_id: loc_id2, name: "two_two"}]
      assert World.Location.look(loc_id2).exits == [%{from_id: loc_id1, name: "one_one"}]

      Supervisor.terminate_child(World, loc_pid(loc_id1))
      Supervisor.terminate_child(World, loc_pid(loc_id2))
    end

    test "kills everything inside it and respawns" do
      loc_id = UUID.uuid4(:hex)
      {:ok, _locpid} = World.start_child(
        %World.Location{
          id: loc_id,
          name: "center of the universe",
          description: "what's on the tin",
          pathways: []}
      )
      {:ok, male_dwarf} = Mobs.birth(
        %{gender: :male, module: Mobs.Dwarf, location_id: loc_id, lifespan: 1000})
      # TODO on second thought maybe the item supervisor shouldn't place
      # the item in the room?
      Item.Supervisor.create(:corpse, loc_id, %{id: "id", name: "Foo"})

      kill_loc(loc_id)

      # TODO oh good, sleeping
      Process.sleep 20
      contents = World.Location.look(loc_id)
      assert length(contents.items) == 0
      assert length(contents.living_things) == 0

      Supervisor.terminate_child(World, loc_pid(loc_id))
    end

  end

end
