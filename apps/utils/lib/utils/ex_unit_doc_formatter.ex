defmodule Utils.ExUnitDocFormatter do
  import ExUnit.Formatter
  use GenServer
  def init(opts \\ %{}) do
    {:ok, %{}}
  end
  def handle_cast({:suite_started, opts}, state) do
    # [include: [], exclude: [], max_cases: 4,
    # seed: 853286, autorun: false,
    # capture_log: false,
    # formatters: [Utils.ExUnitDocFormatter],
    # included_applications: [], colors: [enabled: true],
    # timeout: 60000, trace: false,
    # assert_receive_timeout: 100,
    # case_load_timeout: 60000,
    # refute_receive_timeout: 100,
    # stacktrace_depth: 20]
    {:noreply, state}
  end
  def handle_cast({:suite_finished, run_us, load_us}, state) do
    IO.puts format_time(run_us, load_us)
    {:noreply, state}
  end
  def handle_cast({:case_started, test_case}, state) do
    tests =
      test_case.tests
      |> Enum.reduce(%{}, fn(test, acc) -> Map.put(acc, test.name, %{status: nil}) end)
    state =
      state
      |> Map.put(test_case.name, tests)
    {:noreply, state}
  end
  def handle_cast({:case_finished, test_case}, state) do
    x = case Enum.uniq(Map.values(state[test_case.name])) do
      [:ok] -> "#{test_case.name} is ALL OK"
      _ -> "#{test_case.name} DONE FUCKED UP"
    end
    IO.puts x
    # IO.puts "case finished"
    # IO.inspect test_case
    # IO.puts ""
    {:noreply, state}
  end
  def handle_cast({:test_started, test}, state) do
    {:noreply, state}
  end
  def handle_cast({:test_finished, %{state: nil} = test}, state) do
    state =
      state
      |> update_in([test.case, test.name, :status], fn(_) -> :ok end)
    {:noreply, state}
  end
  def handle_cast({:test_finished, test}, state) do
    state =
      state
      |> update_in([test.case, test.name, :status], fn(_) -> :failed end)
    {:noreply, state}
  end
end
