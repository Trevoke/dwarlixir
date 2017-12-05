defmodule Dwarlixir.Controllers.Mob do
  alias Dwarlixir.{Life, World, Mobs}
  # state %{module, id}

  use GenServer

#  @tick 2000

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    Registry.register(Registry.Tick, :subject_to_time, self())
    {:ok, state}
  end

  def handle_cast(:tick, state) do
    mob_state = Agent.get(state.agent_pid, &(&1))
    new_mob_state = tick(state, mob_state)
    Agent.update(state.agent_pid, fn(_x) -> new_mob_state end)
    {:noreply, state}
  end

  def tick(state, %{lifespan: 0} = mob_state) do
    Agent.stop(state.agent_pid)
    Life.Reaper.claim({state.module, state.id}, mob_state.location_id, mob_state)
    # TODO this needs to be a more elegant "queue message to everyone in the room that the mob died"
    World.Location.announce_death(mob_state.location_id, {{state.module, state.id}, mob_state})
    Registry.unregister(Mobs.Registry, {state.module, state.id})
    GenServer.stop(self())
    Kernel.apply(state.module, :stop, [state.id])
  end

  def tick(state, %{pregnant: true, ticks_to_birth: 1} = mob_state) do
    Kernel.apply(state.module, :new_life, [%{location_id: mob_state.location_id}])
    #TODO add event
    %{mob_state | pregnant: false, ticks_to_birth: nil}
  end

  def tick(state, %{pregnant: true} = mob_state) do
    new_mob_state = let_lady_luck_decide(state, mob_state)
    %{new_mob_state | lifespan: new_mob_state.lifespan - 1, ticks_to_birth: mob_state.ticks_to_birth - 1}
  end

  def tick(state, mob_state) do
    new_mob_state = let_lady_luck_decide(state, mob_state)
    %{new_mob_state | lifespan: new_mob_state.lifespan - 1}
  end

  def let_lady_luck_decide(state, mob_state) do
    case Enum.random(1..10000) do
      x when x < 9000 -> mob_state
      x when x < 9950 -> Kernel.apply(state.module, :move_to_random_location, [mob_state])
      x when x <= 10000 -> Kernel.apply(state.module, :try_to_mate, [mob_state])
      _ -> mob_state
    end
  end

  # Tick when lifespan is 1 -- take all code from `terminate in mob template?`
  # Tick.. When pregnant

  def terminate(reason, _state) do
    Registry.unregister(Registry.Tick, :subject_to_time)
    #Registry.unregister(Controllers.Registry, via_tuple(state.id))
    reason
  end
end
