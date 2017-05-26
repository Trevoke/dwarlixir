defmodule Utils.ServerMacros do
  defmacro defcast(message, payload, do: block) do
    quote do
      def handle_cast({message, payload}, state) do
        Kernel.apply(__MODULE__, unquote(message), [unquote(payload)])
        unquote(block)
        {:noreply, state}
      end
    end
  end
end
