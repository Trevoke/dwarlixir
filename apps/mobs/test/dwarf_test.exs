defmodule Mobs.DwarfTest do
  use ExUnit.Case
  doctest Mobs.Dwarf

  test "gives birth to a baby dwarf" do
    loc_id = UUID.uuid4(:hex)
    {:ok, _locpid} = World.Location.start_link(
      %World.Location{
        id: loc_id,
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    {:ok, female_dwarf} = Mobs.Dwarf.birth(
      %{gender: :female, location_id: loc_id, lifespan: 1000,
              pregnant: true,
        ticks_to_birth: 1,})

    controller = :sys.get_state(female_dwarf).controller_pid
    GenServer.cast(controller, :tick)
    # TODO oh good, sleeping
    Process.sleep 20
    contents = World.Location.look(loc_id)
    assert length(contents.living_things) == 2
  end

end
