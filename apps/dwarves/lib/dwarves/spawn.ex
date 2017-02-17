defmodule Dwarves.Spawn do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: :dwarves_spawn)
  end

  # TODO vary the pleasures
  @genders_and_attraction %{male: :female, female: :male}

  def init(args) do
    rooms =
      World.LocationRegistry
      |> Registry.match(:_, :_)
      |> Enum.map(fn({_, room_id}) -> room_id end)

    IO.inspect rooms

    Enum.each((1..40), fn x ->
      initial_loc =
        rooms
        |> Enum.shuffle
        |> List.first
      birth(initial_loc, lifespan: args)
    end)
    {:ok, %{}}
  end

  def handle_cast({:birth, %{location: location, lifespan: lifespan_type}}, state) do
    birth(location, lifespan: lifespan_type)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp birth(location_id, lifespan: lifespan_type) do
    lifespan = random_lifespan(lifespan_type)
    gender =
      @genders_and_attraction
      |> Enum.shuffle
      |> List.first
    {:ok, _} = Dwarf.start_link(
      %{
        location: location_id,
        name: Faker.Name.name,
        lifespan: lifespan,
        gender: gender
      })
  end


  defp random_lifespan({:short_lifespan}), do: 180 + :rand.uniform(720)
  defp random_lifespan(_args), do: 1800 + :rand.uniform(7200)
end
