defmodule MetaPidRequest.PlugTest do
  use ExUnit.Case
  use Plug.Test

  alias MetaPidRequest.RequestMetadata

  setup do
    {:ok, pid} = MetaPidRequest.start_link()
    %{server: pid}
  end

  defp run_scenario(scenario_fn) do
    t = Task.async(fn () ->
      conn_pid = self

      conn(:get, "/")
      |> Plug.RequestId.call(Plug.RequestId.init([]))
      |> MetaPidRequest.Plug.call([])

      scenario_fn.(conn_pid)

      MetaPidRequest.fetch_metadata(conn_pid)
    end)

    {:ok, result} = Task.await(t)

    result
  end

  defp make_time_key(n) do
    "service_#{n}" |> String.to_atom()
  end

  test "handles a single connection with a synchronous operation" do
    result = run_scenario(fn (conn_pid) ->
      Enum.each(0..10, fn (n) ->
        {:ok, data} = MetaPidRequest.fetch_metadata(conn_pid)

        data
        |> RequestMetadata.add_time(make_time_key(n), n)
        |> (fn (data) -> MetaPidRequest.put_metadata(conn_pid, data) end).()
      end)
    end)

    expected = Enum.reduce(0..10, Map.new, fn (n, acc) ->
      Map.put(acc, make_time_key(n), [n])
    end)

    assert result.times == expected
  end

  test "handles several concurrent connections each with a synchronous operation" do
    tasks = Enum.map(0..9, fn (_) ->
      Task.async(fn () ->
        run_scenario(fn (conn_pid) ->
          {:ok, data} = MetaPidRequest.fetch_metadata(conn_pid)

          time_key = "#{data.request_id}-service" |> String.to_atom()

          data
          |> RequestMetadata.add_time(time_key, 5)
          |> (fn (data) -> MetaPidRequest.put_metadata(conn_pid, data) end).()
        end)
      end)
    end)

    results = tasks |> Task.yield_many() |> Enum.map(fn ({_, {:ok, result}}) -> result end)

    assert results |> Enum.count == 10
  end

  test "handles several concurrent tasks within a single connection adding service call times for a pid" do
    result = run_scenario(fn (conn_pid) ->
      tasks = Enum.map(0..10, fn (n) ->
        Task.async(fn () ->
          MetaPidRequest.add_time(conn_pid, :service_foo, n)
        end)
      end)

      _ = Task.yield_many(tasks)
    end)

    times = result.times |> Map.get(:service_foo)

    assert times |> Enum.count == 11
    assert times |> MapSet.new == (for n <- 0..10, into: MapSet.new do n end)
  end
end
