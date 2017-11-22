defmodule Ecs.InvalidComponentError do
  @moduledoc "Thrown when a component can't be recognized."
  defexception [:message]
  def exception(not_a_component) do
    msg = "Whatever this is, it's not a component: '#{inspect not_a_component}'"
    %Ecs.InvalidComponentError{message: msg}
  end
end
