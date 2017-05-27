defmodule Utils.ServerMacros do
  @moduledoc """
  Macros for automatic API / callback generation
  for genservers
  """


  defmacro __using__(_opts) do
    quote do
      import Utils.ServerMacros
    end
  end

  # TODO - macro with no payload
  # TODO - more than one argument
  # TODO - use via_tuple
  # TODO - tell people that without a via_tuple
  # life is gonna suck
  #
  # TODO - what about other returns like :stop?
  #
  # TODO - defcall
  #
  # TODO - document the "do_foo"

  @doc """
  REQUIRES a `via_tuple/1` function to be defined.
  REQUIRES a `do_foo` function to be defined with the correct arity.

  Defines an API function and a related async callback:

  defcast(:arrive, loc_id, mob) do
    # stuff
  end

  will create:

  def arrive(loc_id, mob) do
    GenServer.cast(via_tuple(loc_id), {:arrive, mob})
  end

  def handle_cast({:arrive, mob}, state) do
    new_state = do_arrive(mob, state)
    # stuff
    {:noreply, new_state}
  end
  """
  defmacro defcast(message, id, payload, do: block) do
    quote do

      def unquote(message)(payload) do
        GenServer.cast(via_tuple(unquote(id)), {unquote(message), unquote(payload)})
      end

      def handle_cast({message, payload}, state) do
        unquote(block)
        state = Kernel.apply(__MODULE__, :"do_#{unquote(message)}", [unquote(payload), state])
        {:noreply, state}
      end
    end
  end
end
