defmodule Mobs.BirdTest do
  use ExUnit.Case
  doctest Mobs.Bird

  test "only mates with birds" do

    # TODO this test is still bogus but it makes
    # more sense now at least

    import IEx
    {:ok, foo} = World.Location.start_link(
      %World.Location{
        id: "2",
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    female_bird = Mobs.Spawn.birth(
      %{module: Mobs.Bird, location_id: "2", gender: :female})
    male_dwarf = Mobs.Spawn.birth(
      %{module: Mobs.Dwarf, location_id: "2", gender: :male})

    {:noreply, new_state} = Mobs.Bird.handle_cast(:try_to_mate, %Mobs.Bird{location_id: "2", gender: :female, name: "Female McFemale", pregnant: nil})

    # Not actually meaningful because I make a call to pregnantize
    assert new_state.pregnant == nil

    Mobs.Dwarf.stop(male_dwarf)

    male_bird = Mobs.Spawn.birth(
      %{module: Mobs.Bird, location_id: "2", gender: :male})

    ref = Process.monitor(GenServer.whereis({:via, Registry, {Registry.Mobs, female_bird}}))

    Mobs.Bird.handle_cast(:try_to_mate, %Mobs.Bird{location_id: "2", gender: :female, name: "Female McFemale", pregnant: nil})

    assert_receive :pregnantize, 100

  end

end
