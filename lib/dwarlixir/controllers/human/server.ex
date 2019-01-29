defmodule Dwarlixir.Controllers.Human.Server do
  use GenServer

  def start_link(args \\ %Dwarlixir.Controllers.Human{}) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id, args.id))
  end

  def init(args) do
    Registry.register(Registry.Controllers, "human", args.id)
    {:ok, args}
  end

  def via_tuple(id, value) do
    {:via, Registry, {Registry.HumanControllers, id, value}}
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.HumanControllers, id}}
  end

  def handle(user_id, message) do
    GenServer.cast(via_tuple(user_id), message)
  end

  def handle_cast({:input, input}, state) do
    state.transport.send(state.socket, input)
    {:noreply, state}
  end
end
