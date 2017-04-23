defmodule Mobs.MobTemplate do

  defmacro __using__(_) do
    quote do
      defstruct [
        :id, :location_id, :lifespan,
        :gender, :controller, :pregnant,
        name: "", exits: []
      ]
      use GenServer

      def start(args) do
        GenServer.start(__MODULE__, args, name: via_mob(args.id), restart: :transient)
      end

      defp via_mob(id), do: {:via, Registry, {Mobs.Registry, id}}

      def init(%__MODULE__{location_id: location_id} = state) do
        Process.flag(:trap_exit, true)
        {:ok, exits} = World.Location.arrive(location_id, {{__MODULE__, state.id}, public_info(state), "seemingly nowhere"})
        new_state = %__MODULE__{state | exits: exits}
        {:ok, pid} = Controllers.Mob.start_link(%{module: __MODULE__, id: new_state.id, timer_ref: nil, mob_state: new_state})
        {:ok, %__MODULE__{new_state | controller: pid}}
      end

      def handle(id, message), do: GenServer.cast(via_mob(id), message)

      def set_location(mob_id, loc_id, exits), do: GenServer.cast(via_mob(mob_id), {:set_location, loc_id, exits})
      def handle_cast({:set_location, loc_id, exits}, state), do: {:noreply, %__MODULE__{state | location_id: loc_id, exits: exits}}

      def decrement_lifespan(id), do: GenServer.cast(via_mob(id), :decrement_lifespan)

      def handle_cast(:decrement_lifespan, %__MODULE__{lifespan: 1} = state) do
        #TODO add event here?
        {:stop, :normal, %__MODULE__{state | lifespan: 0}}
      end

      def handle_cast(:decrement_lifespan, state) do
        {:noreply, %__MODULE__{state | lifespan: state.lifespan - 1}}
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

      # spec: state :: state
      # TODO return list of messages out of here... ?
      def try_to_mate(state) do
        looking_for = case state.gender do
                        :male -> :female
                        :female -> :male
                      end

        possible_partners = World.Location.mobs(state.location_id)

        {:ok, {new_state, messages}} =
          Mobs.SexualReproduction.call(
            {state, []},
            {
              state.gender,
              looking_for,
              __MODULE__,
              possible_partners
            })

        Enum.each(messages, fn({m, f, arglist}) -> Kernel.apply(m, f, arglist) end)
        new_state
      end

      def depregnantize(id), do: GenServer.cast(via_mob(id), :depregnantize)
      def handle_cast(:depregnantize, state), do: {:noreply, %__MODULE__{state | pregnant: :false}}

      # This has made so many people laugh that I can't rename it.
      def pregnantize(mob_id) do
        GenServer.cast(via_mob(mob_id), :pregnantize)
      end

      def handle_cast(:pregnantize, state) do
        GenServer.cast(state.controller, :pregnantize)
        new_state = %__MODULE__{state | pregnant: true}
        {:noreply, new_state}
      end

      def stop(mob_id) do
        GenServer.stop(via_mob(mob_id))
      end

      def terminate(reason, state) do
        Registry.unregister(Mobs.Registry, {__MODULE__, state.id})
        GenServer.stop(state.controller)
        Life.Reaper.claim({__MODULE__, state.id}, state.location_id, public_info(state))
        World.Location.depart(state.location_id, {{__MODULE__, state.id}, public_info(state), "to a better place"})
        reason
      end

      defp public_info(state) do
        %{
          gender: state.gender,
          name: state.name,
          pregnant: state.pregnant
        }
      end

      #TODO this will be helpful
      #defp leave("to nothingness"), do: ""

    end
  end
end
