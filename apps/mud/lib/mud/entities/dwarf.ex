defmodule Mud.Entities.Dwarf do
  alias Ecs.Entity
  alias Mud.Components

  @default_components [
    Components.Race.Dwarf,
    Components.Age,
    Components.Mortality,
    Components.SexualReproduction,
    Components.Social,
    Components.Room,
    Components.Description,
    Components.AI
  ]

  def new(components) when is_list(components) do
    Entity.new(components: build_component_list(components, @default_components))
  end

  def new do
    Entity.new(components: @default_components)
  end


  defp build_component_list([], acc), do: acc
  defp build_component_list([component | components], acc)
  when is_atom(component) do
    if Enum.find(acc, fn(x) -> x == component) do
      build_component_list(components, acc)
    else
      build_component_list(components, [component | acc])
    end
  end
  defp build_component_list([%{type: _t} = component | components], acc) do
    if Enum.find(acc, fn(x) -> x == component.type) do
      build_component_list(components, acc)
    else
      build_component_list(components, [component | acc])
    end
  end
end
