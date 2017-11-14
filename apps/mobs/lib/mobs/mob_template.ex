defmodule Mobs.MobTemplate do

  defmacro __using__(_) do
    quote do
      defstruct [
        :id,
        :location_id, # => LocationComponent
        #:lifespan, # => RaceComponent
        #:gender, # => Sex / Biology / Placental / Mammal / Sexual / Repro?
        :controller, # => ControllerComponent / AIComponent
        #:pregnant, # => PregnancyComponent
        #:ticks_to_birth, # => PregnancyComponent
        name: "", # => SocialComponent
        exits: []
      ]
      use GenServer

      def start_link(args) do
        GenServer.start(__MODULE__, args, name: via_tuple(args.id), restart: :transient)
      end

      def via_tuple(id), do: {:via, Registry, {Mobs.Registry, id}}

      def init(%__MODULE__{location_id: location_id} = state) do
        {:ok, exits} = World.Location.arrive(location_id, {{__MODULE__, state.id}, public_info(state), "seemingly nowhere"})
        new_state = %{state | exits: exits}
        # TODO remove timer ref?
        {:ok, apid} = Agent.start_link(fn() -> new_state end)
        {:ok, cpid} = Controllers.Mob.start_link(%{module: __MODULE__, id: new_state.id, agent_pid: apid})
        {:ok, %{agent_pid: apid, controller_pid: cpid, id: state.id}}
      end

      def set_location(mob_id, loc_id, exits), do: GenServer.cast(via_tuple(mob_id), {:set_location, loc_id, exits})
      def handle_cast({:set_location, loc_id, exits}, state) do
        Agent.update(state.agent_pid, fn(x) -> Map.merge(x, %{location_id: loc_id, exits: exits}) end)
        {:noreply, state}
      end

      def handle_cast({:arrive, info, from_loc}, state) do
        {:noreply, state}
      end

      def handle_cast({:depart, info, to_loc}, state) do
        {:noreply, state}
      end

      # spec: state :: state
      # TODO more like reproduction, return state and list of messages?
      def move_to_random_location(%{location_id: loc_id, id: id, exits: exits} = state) do
        with true <- Enum.any?(exits),
             info <- public_info(state),
               %{from_id: new_loc_id} <- Enum.random(exits),
               :ok <- World.Location.depart(loc_id, {{__MODULE__, id}, info, new_loc_id}),
             {:ok, new_exits} <- World.Location.arrive(new_loc_id, {{__MODULE__, id}, info, loc_id}) do
          %{state | location_id: new_loc_id, exits: new_exits}
        else
          false -> state
        :not_in_location -> state
        end
      end

      def try_to_mate(%{pregnant: true} = state), do: state
      # spec: state :: state
      # TODO return list of messages out of here... ?
      def try_to_mate(state) do
        looking_for = case state.gender do
                        :male -> :female
                        :female -> :male
                      end

        possible_partners_task =
          Task.async(World.Location, :mobs, [state.location_id])

        case Task.yield(possible_partners_task, 50) || Task.shutdown(possible_partners_task) do
          nil -> state
          {:ok, possible_partners} ->
            {:ok, {new_state, messages}} = Mobs.SexualReproduction.call({state, []}, {state.gender, looking_for, __MODULE__, possible_partners})
            # TODO Task for this
            Enum.each(messages, fn({m, f, arglist}) -> Kernel.apply(m, f, arglist) end)
            new_state
        end
      end

      def depregnantize(id), do: GenServer.cast(via_tuple(id), :depregnantize)
      def handle_cast(:depregnantize, state) do
        Agent.update(state.agent_pid, fn(x) -> Map.merge(x, %{pregnant: false, ticks_to_birth: nil}) end)
        {:noreply, state}
      end

      # This has made so many people laugh that I can't rename it.
      def pregnantize(mob_id) do
        GenServer.cast(via_tuple(mob_id), :pregnantize)
      end

      def handle_cast(:pregnantize, state) do
        Agent.update(state.agent_pid, fn(x) -> Map.merge(x, %{pregnant: true, ticks_to_birth: 100}) end)
        {:noreply, state}
      end

      def handle(id, message), do: GenServer.cast(via_tuple(id), message)

      # Yeah so this should actually *do* something
      # But for now it'll help avoid mailboxes getting full.
      def handle_cast(_msg, state), do: {:noreply, state}

      def stop(mob_id) do
        GenServer.stop(via_tuple(mob_id))
      end

      defp public_info(state) do
        %{
          gender: state.gender,
          name: state.name,
          pregnant: state.pregnant
        }
      end

    end
  end
end
