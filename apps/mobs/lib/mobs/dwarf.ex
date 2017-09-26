defmodule Mobs.Dwarf do
  use Mobs.MobTemplate

  def new_life(%{location_id: _x} = options) do
    birth =
      Task.async(
        __MODULE__,
        :birth,
        [options]
      )

    Task.yield(birth, 50) || Task.shutdown(birth)
  end

  def birth(%{location_id: loc_id} = options) do
    import Supervisor.Spec, warn: false
    id = new_id()
    state = %{lifespan_type: Application.get_env(:mobs, :lifespan)}
    gender = options[:gender] || Enum.random([:male, :female])
    lifespan = random_lifespan(state.lifespan_type)

    initial_values = %{
      id: id,
      location_id: loc_id,
      gender: gender,
      name: Faker.Name.name,
      lifespan: lifespan
    }

    initial_values = Map.merge(options, initial_values)

    dwarf = worker(
      Mobs.Dwarf,
      [struct(Mobs.Dwarf, initial_values)],
      [id: id]
    )

    Supervisor.start_child(Mobs.Supervisor, dwarf)
  end

  defp new_id, do: UUID.uuid4(:hex)

  defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)

end
