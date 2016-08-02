defmodule MetaPidRequest.PlugTest do
  use ExUnit.Case
  use Plug.Test

  alias Plug.Conn
  alias MetaPidRequest.RequestMetadata

  setup do
    {:ok, pid} = MetaPidRequest.start_link()
    %{server: pid}
  end

  defp make_request_id(id) do
    "request_#{id}"
  end

  defp make_time_key(id) do
    "service_#{id}" |> String.to_atom()
  end

  test "handles multiple requests simultaneously" do
    request_tasks = Enum.map(1..4, fn (id) ->
      Task.async(fn () ->
        base_conn  = conn(:get, "/test")
        connection = Conn.put_req_header(base_conn, "x-request-id", make_request_id(id))
        MetaPidRequest.Plug.call(connection, MetaPidRequest.Plug.init([]))

        parent = self

        task = Task.async(fn () ->
          Process.group_leader(self, parent)

          {:ok, current_data} = MetaPidRequest.fetch_metadata(self)


          MetaPidRequest.put_metadata(
            self,
            RequestMetadata.add_time(current_data, make_time_key(id), id)
          )

          :ok
        end)

        Task.await(task)

        {:ok, metadata} = MetaPidRequest.fetch_metadata(self)

        metadata
      end)
    end)

    results = Task.yield_many(request_tasks)
    |> Enum.map(fn ({_, {:ok, result}}) -> result end)
    |> Enum.map(fn (result) -> %{request_id: result.request_id, times: result.times} end)
    |> MapSet.new

    expected = Enum.map(1..4, fn (id) ->
      %{
        request_id: make_request_id(id),
        times:      Map.put(Map.new, make_time_key(id), [id])
      }
    end)
    |> MapSet.new


    assert results == expected
  end
end
