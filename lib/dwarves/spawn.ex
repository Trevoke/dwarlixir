defmodule Dwarves.Spawn do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: :dwarves_spawn)
  end

  @genders [:male, :female]

  def init(args) do
    Enum.each((1..40), fn x ->
      initial_loc = {x, x}
      birth(initial_loc, lifespan: args)
    end)
    {:ok, %{}}
  end

  def handle_cast({:birth, %{location: {x, y}, lifespan: lifespan}}, state) do
    birth({x, y}, lifespan: lifespan)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp birth(location, lifespan: lifespan) do
    lifespan = random_lifespan(lifespan)
    {:ok, _} = Dwarf.start_link(
      %{
        location: location,
        name: Faker.Name.name,
        lifespan: lifespan,
        gender: List.first Enum.shuffle(@genders)
      })
  end


  defp random_lifespan({:short_lifespan}), do: 180 + :rand.uniform(720)
  defp random_lifespan(_args), do: 1800 + :rand.uniform(7200)
end
