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
    {:ok, male_dwarf} = Mobs.birth(
      %{gender: :male, module: Mobs.Dwarf, location_id: loc_id, lifespan: 1000})
    {:ok, female_dwarf} = Mobs.birth(
      %{gender: :female, module: Mobs.Dwarf, location_id: loc_id, lifespan: 1000})

    controller = :sys.get_state(male_dwarf).controller
    GenServer.cast(controller, :tick)
    # TODO oh good, sleeping
    Process.sleep 20
    contents = World.Location.look(loc_id)
    #assert length(contents.items) == 1
  end

end
