defmodule World.Supervisor do
  use Supervisor

  def start_link(opts \\ %{}) do
    location_spec =
      Supervisor.child_spec(
        World.Location,
        start: {World.Location, :start_link, []}
      )

    Supervisor.start_link(
      [location_spec],
      strategy: :simple_one_for_one,
      name: __MODULE__
    )
  end

  def start_child(opts) do
    Supervisor.start_child(__MODULE__, [opts])
  end

  def random_room_id do
    Registry.match(World.Registry, "location", :_)
    |> Enum.map(fn({_, id}) -> id end)
    |> Enum.random
  end

end
