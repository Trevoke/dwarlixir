defmodule Mobs.Dwarf do
  defstruct [
    :id, :location_id, :lifespan,
    :gender, :controller, :pregnant,
    name: ""
  ]
  use GenServer

  alias World.{Location, Pathway}
  alias Mobs.Dwarf

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_mob(args.id), restart: :transient)
  end

  defp via_mob(id), do: {:via, Registry, {Registry.Mobs, id}}

  def init(%Dwarf{location_id: location_id} = state) do
    {:ok, pid} = GenericMobController.start_link(%{id: state.id, timer_ref: nil})
    Location.arrive(location_id, {{__MODULE__, state.id}, public_info(state)}, {"seemingly nowhere", nil})
    {:ok, %Dwarf{state | controller: pid}}
  end

  def tick(mob_id) do
    GenServer.cast(via_mob(mob_id), :tick)
  end

  def gender(mob_id) do
    GenServer.call(via_mob(mob_id), :gender)
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


  def handle_cast(:tick, %Dwarf{lifespan: 0} = state), do: {:noreply, state}
  def handle_cast(:tick, %Dwarf{name: name, lifespan: 1} = state) do
    #TODO add event
    Life.Reaper.claim(state.id, state.location_id, public_info(state))
    {:noreply, %Dwarf{state | lifespan: 0}}
  end

  def handle_cast(:tick, %Dwarf{lifespan: lifespan, pregnant: true} = state) do
    Mobs.Spawn.birth(location: state.location_id)
    #TODO add event
    {:noreply, %Dwarf{state | lifespan: lifespan - 1, pregnant: false}}
  end

  def handle_cast(:tick, %Dwarf{lifespan: lifespan} = state) do

    new_state = case Enum.random(1..1000) do
                  x when x < 990 -> move_to_random_location(state)
                  _ -> try_to_mate(state)
                  #_ -> state
                end

    {:noreply, %Dwarf{new_state | lifespan: lifespan - 1}}
  end

  def handle_cast(:pregnantize, state) do
    {:noreply, %Dwarf{state | pregnant: true}}
  end

  def handle_call(:gender, _from, state) do
    {:reply, state.gender, state}
  end

  defp move_to_random_location(%Dwarf{location_id: loc_id, id: id} = state) do
    new_loc = Enum.random Pathway.exits(loc_id)
    Location.move(loc_id, {Dwarf, id}, new_loc, public_info(state))
    %Dwarf{state | location_id: new_loc}
  end

  defp try_to_mate(state) do
    looking_for = case state.gender do
                    :male -> :female
                    :female -> :male
                  end

    possible_partners =
      Location.mobs(
        state.location_id,
        fn({_, info}) -> info.gender == looking_for end
      )

    if Enum.empty? possible_partners do
      state
    else

      partner = Enum.random possible_partners

      case [state.gender, elem(partner, 1).gender] do
        [:male, :female] -> Dwarf.pregnantize(elem(partner, 0))
        [:female, :male] ->  Dwarf.pregnantize(state.id)
      end

      state
    end
  end

  def stop(mob_id) do
    # TODO stop the controller and other associated processes here
    GenServer.stop(via_mob(mob_id))
  end

  defp public_info(state) do
    %{
      gender: state.gender,
      name: state.name
    }
  end

end
