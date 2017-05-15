defmodule Mobs.SexualReproduction do
  # entities_around is of the form %{{module, id} => public_info}
  def call({state, messages}, {:male, :female, my_species, entities_around}) do
    possible_females =
      Enum.filter(
        entities_around,
        fn({{their_species, _}, their_stats}) ->
          their_species == my_species &&
            their_stats.gender == :female &&
            their_stats.pregnant == false
        end
      )

    if Enum.empty? possible_females do
      {:ok, {state, messages}}
    else
      # TODO genetics
      {{module, id}, info} =
        possible_females
        |> Enum.random
      {:ok, {state, [{module, :pregnantize, [id]}  | messages]}}
    end
  end

  def call({state, messages}, {:female, :male, my_species, entities_around}) do
    possible_males =
      Enum.filter(
        entities_around,
        fn({{their_species, _}, their_stats}) ->
          their_species == my_species && their_stats.gender == :male
        end
      )

    if Enum.empty? possible_males do
      {:ok, {state, messages}}
    else
      # TODO : genetics
      {{module, id}, info} =
        possible_males
        |> Enum.random
      {:ok, {state, [{my_species, :pregnantize, [state.id]}  | messages]}}
    end
  end

  def call({state, messages}, args), do: {state, messages}

end
