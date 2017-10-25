defmodule Ecs.GlobalState do
  use GenServer
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(args) do
    :ets.new(__MODULE__, [:set, :named_table, :protected])
    {:ok, args}
  end

  def get_components_by_type(type) do
    [components] = :ets.match(Ecs.GlobalState, {{type, :'_'}, :'$1'})
    components
  end

  def get_component_by_id(id) do
    [[component]] = :ets.match(Ecs.GlobalState, {{:'_', id}, :'$1'})
    component
  end

  def save_component(component) do
    GenServer.call(__MODULE__, {:save_component, component})
  end

  def save_entity(entity) do
    GenServer.cast(__MODULE__, {:save_entity, entity})
  end

  def handle_call({:save_component, component}, _from, state) do
    :ets.insert(__MODULE__, {{component.type, component.id}, component})
    {:reply, :ok, state}
  end

  def handle_cast({:save_entity, entity}, state) do
    Enum.each(entity.components, fn(component) ->
      nil
#      :ets.insert(__MODULE__, {{:entity_component, entity.id, component.id}, })
    end)
    :ets.insert(__MODULE__, {{:entity, entity.id}, entity})
    {:noreply, state}
  end

end
