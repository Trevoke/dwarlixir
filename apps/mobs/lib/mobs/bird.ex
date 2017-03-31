defmodule Mobs.Bird do
  defstruct [
    :id, :location_id, :lifespan,
    :gender, :controller, :pregnant,
    name: ""
  ]
  use GenServer

  alias World.Pathway

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_mob(args.id), restart: :transient)
  end

  defp via_mob(id), do: {:via, Registry, {Registry.Mobs, id}}

  def init(%__MODULE__{location_id: location_id} = state) do
    {:ok, pid} = Controllers.Mob.start_link(%{module: __MODULE__, id: state.id, timer_ref: nil})
    World.Location.arrive(location_id, {{__MODULE__, state.id}, public_info(state)}, "seemingly nowhere")
    {:ok, %__MODULE__{state | controller: pid}}
  end

  def tick(mob_id) do
    GenServer.cast(via_mob(mob_id), :tick)
  end

  def handle(id, message) do
    GenServer.cast(via_mob(id), message)
  end

  # This has made so many people laugh that I can't rename it.
  def pregnantize(mob_id) do
    GenServer.cast(via_mob(mob_id), :pregnantize)
  end

  def handle_cast({:arrive, info, from_loc}, state) do
    {:noreply, state}
  end

  def handle_cast(:tick, %__MODULE__{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast(:tick, %__MODULE__{name: name, lifespan: 1} = state) do
    #TODO add event
    Life.Reaper.claim({__MODULE__, state.id}, state.location_id, public_info(state))
    {:noreply, %__MODULE__{state | lifespan: 0}}
  end

  def handle_cast(:tick, %__MODULE__{lifespan: lifespan, pregnant: true} = state) do
    Mobs.Spawn.birth(%{module: __MODULE__, location_id: state.location_id})
    #TODO add event
    new_state = %__MODULE__{state | lifespan: lifespan - 1, pregnant: false}
    World.Location.update_public_info(new_state.location_id, {__MODULE__, new_state.id, public_info(new_state)})
    {:noreply, new_state}
  end

  def handle_cast(:tick, %__MODULE__{lifespan: lifespan} = state) do

    new_state = case Enum.random(1..1000) do
                  x when x < 930 -> move_to_random_location(state)
                  _ -> try_to_mate(state.id) && state
                  #_ -> state
                end

    {:noreply, %__MODULE__{new_state | lifespan: lifespan - 1}}
  end

  def handle_cast(:pregnantize, state) do
    new_state = %__MODULE__{state | pregnant: true}
    World.Location.update_public_info(new_state.location_id, {__MODULE__, new_state.id, public_info(new_state)})
    {:noreply, new_state}
  end

  def handle_cast(:try_to_mate, state) do
    looking_for = case state.gender do
                    :male -> :female
                    :female -> :male
                  end

    possible_partners = World.Location.mobs(state.location_id, fn({{module, id}, info}) -> module == Mobs.Bird && info.gender == looking_for end)

    if Enum.any? possible_partners do
      partner = Enum.random possible_partners

      case [state.gender, elem(partner, 1).gender] do
        [:male, :female] -> __MODULE__.pregnantize(elem(partner, 0))
        [:female, :male] -> __MODULE__.pregnantize(state.id)
      end
    end
    {:noreply, state}
  end

  defp move_to_random_location(%__MODULE__{location_id: loc_id, id: id} = state) do
    new_loc = Enum.random Pathway.exits(loc_id)
    World.Location.move(loc_id, {__MODULE__, id}, new_loc, public_info(state))
    %__MODULE__{state | location_id: new_loc}
  end

  def try_to_mate(id) do
    GenServer.cast(via_mob(id), :try_to_mate)
  end

  def stop(mob_id) do
    GenServer.stop(via_mob(mob_id))
  end

  def terminate(reason, state) do
    GenServer.stop(state.controller)
    reason
  end

  defp public_info(state) do
    %{
      gender: state.gender,
      name: state.name,
      pregnant: state.pregnant
    }
  end

end
