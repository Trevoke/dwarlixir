defmodule Dwarves.Spawn do
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: :dwarves_spawn)
  end

  def init(args) do
    Enum.each((1..40), fn id ->
      initial_loc =
        ["1", "2", "3"]
        |> Enum.shuffle
        |> List.first
      birth(id, initial_loc, lifespan: args)
    end)
    {:ok, nil}
  end

  def handle_cast({:birth, %{id: id, location: location, lifespan: lifespan_type}}, state) do
    birth(id, location, lifespan: lifespan_type)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp birth(id, location_id, lifespan: lifespan_type) do
    lifespan = random_lifespan(lifespan_type)
    {:ok, _} = Dwarf.start_link(
      %Dwarf{
        id: id,
        location_id: location_id,
        name: Faker.Name.name,
        lifespan: lifespan
      })
  end


  defp random_lifespan({:short_lifespan}), do: 180 + :rand.uniform(720)
  defp random_lifespan(_args), do: 1800 + :rand.uniform(7200)
end
