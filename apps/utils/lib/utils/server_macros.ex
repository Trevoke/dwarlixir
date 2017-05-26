defmodule Utils.ServerMacros do
  @moduledoc """
  Macros for automatic API / callback generation
  for genservers
  """

  # TODO - macro with no payload

  # TODO - use via_tuple
  # TODO - tell people that without a via_tuple
  # life is gonna suck
  #
  # TODO - what about other returns like :stop?
  #
  # TODO - defcall
  #
  # TODO - document the "do_foo"

  defmacro defcast(message, payload, do: block) do
    quote do

      def unquote(message)(payload) do
        GenServer.cast(__MODULE__, {unquote(message), unquote(payload)})
      end

      def handle_cast({message, payload}, state) do
        Kernel.apply(__MODULE__, :"do_#{unquote(message)}", [unquote(payload)])
        unquote(block)
        {:noreply, state}
      end
    end
  end
end
