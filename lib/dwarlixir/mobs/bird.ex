defmodule Dwarlixir.Mobs.Bird do
  use Ecstatic.Entity

  alias Dwarlixir.Components, as: C

  def default_components: [C.Age, C.Mortal]


  # TODO reproduction will involve laying eggs


  defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)

end
