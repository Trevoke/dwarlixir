defmodule Controllers.Mob do
  # state %{module, id, mob_state}

  use GenServer

#  @tick 2000

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    Registry.register(Registry.Tick, :subject_to_time, self())
    {:ok, %{state | mob_state: Map.from_struct(state.mob_state) }}
  end

  #def via_tuple(id), do: {:via, Registry, {Controllers.Registry, id}}

  def handle_cast(:tick, %{mob_state: %{lifespan: 1}} = state) do
    #TODO add event here?
    Kernel.apply(state.module, :decrement_lifespan, [state.id])
    {:noreply, %{state | mob_state: %{state.mob_state | lifespan: 0}}}
  end

  def handle_cast(:tick, %{mob_state: %{
                              lifespan: lifespan,
                              pregnant: true,
                              ticks_to_birth: 1}
                          } = state) do
    birth =
      Task.async(
        Mobs,
        :birth,
        [
          %{module: state.module, location_id: state.mob_state.location_id}
        ])

    Task.yield(birth, 50) || Task.shutdown(birth)

    #TODO add event
    new_state = %{state | mob_state: %{state.mob_state | lifespan: lifespan - 1, pregnant: false}}
    Kernel.apply(state.module, :depregnantize, [state.id])
    Kernel.apply(state.module, :decrement_lifespan, [state.id])
    {:noreply, new_state}
  end

  def handle_cast(:tick, %{mob_state: %{
                              lifespan: lifespan,
                              pregnant: true,
                              ticks_to_birth: ticks_to_birth}} = state) do
    new_mob_state = tick(state)
    Kernel.apply(state.module, :decrement_lifespan, [state.id])
    #Kernel.apply(state.module, :set_location, [state.id, new_mob_state.location_id, new_mob_state.exits])
    {:noreply, %{state | mob_state: %{new_mob_state | lifespan: lifespan - 1,
                                     ticks_to_birth: ticks_to_birth - 1}}}
  end

  def tick(state) do
    case Enum.random(1..10000) do
      x when x < 9000 -> state.mob_state
      x when x < 9950 -> Kernel.apply(state.module, :move_to_random_location, [state.mob_state])
      x when x <= 10000 -> Kernel.apply(state.module, :try_to_mate, [state.mob_state])
      _ -> state.mob_state
    end
  end

  def handle_cast(:tick, %{mob_state: %{lifespan: lifespan}} = state) do
    new_mob_state = tick(state)
    Kernel.apply(state.module, :decrement_lifespan, [state.id])
    #Kernel.apply(state.module, :set_location, [state.id, new_mob_state.location_id, new_mob_state.exits])
    {:noreply, %{state | mob_state: %{new_mob_state | lifespan: lifespan - 1}}}
  end

  def handle_cast({:pregnantize, ticks_to_birth}, state) do
    {:noreply, %{state | mob_state: %{state.mob_state | pregnant: :true,
                                     ticks_to_birth: ticks_to_birth}}}
  end

  def terminate(reason, _state) do
    Registry.unregister(Registry.Tick, :subject_to_time)
    #Registry.unregister(Controllers.Registry, via_tuple(state.id))
    reason
  end
end
