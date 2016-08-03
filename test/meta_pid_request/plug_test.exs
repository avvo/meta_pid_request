defmodule MetaPidRequest.PlugTest do
  use ExUnit.Case

  alias MetaPidRequest.RequestMetadata

  def make_time_key(n) do
    "service_#{n}" |> String.to_atom()
  end

  defmodule ResultsServer do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    end

    def stop() do
      GenServer.stop(__MODULE__)
    end

    def report_results(data) do
      GenServer.call(__MODULE__, {:report_results, data})
    end

    def get_results() do
      GenServer.call(__MODULE__, :get_results)
    end

    def init(_) do
      {:ok, MapSet.new}
    end

    def handle_call({:report_results, data}, _from, existing) do
      {:reply, :ok, MapSet.put(existing, data)}
    end

    def handle_call(:get_results, _from, data) do
      {:reply, data, data}
    end
  end

  setup do
    {:ok, pid} = MetaPidRequest.start_link()
    %{server: pid}
  end

  setup do
    {:ok, pid} = ResultsServer.start_link()
    %{results_server: pid}
  end

  describe "Scenario #1" do
    defmodule Scenario1 do
      use Plug.Builder

      plug Plug.RequestId, http_header: "x-request-id"
      plug MetaPidRequest.Plug
      plug :scenario
      plug :respond

      def scenario(conn, _) do
        Enum.each(0..10, fn (n) ->
          {:ok, data} = MetaPidRequest.fetch_metadata(self)

          data
          |> RequestMetadata.add_time(MetaPidRequest.PlugTest.make_time_key(n), n)
          |> (fn (data) -> MetaPidRequest.put_metadata(self, data) end).()
        end)

        {:ok, data} = MetaPidRequest.fetch_metadata(self)

        MetaPidRequest.PlugTest.ResultsServer.report_results(data)

        conn
      end

      def respond(conn, _) do
        conn |> send_resp(200, "ok")
      end
    end

    setup do
      {:ok, _} = Plug.Adapters.Cowboy.http(Scenario1, [], [ref: :scenario1])

      on_exit fn () ->
        Plug.Adapters.Cowboy.shutdown(:scenario1)
      end

      :ok
    end

    test "handles a single connection with a synchronous operation" do
      HTTPoison.get!("http://localhost:4000")

      results  = ResultsServer.get_results() |> MapSet.to_list |> hd |> Map.get(:times)
      expected = Enum.reduce(0..10, Map.new, fn (n, acc) ->
        Map.put(acc, make_time_key(n), [n])
      end)

      assert results == expected
    end
  end

  describe "Scenario #2" do
    defmodule Scenario2 do
      use Plug.Builder

      plug Plug.RequestId, http_header: "x-request-id"
      plug MetaPidRequest.Plug
      plug :scenario
      plug :respond

      def scenario(conn, _) do
        {:ok, data} = MetaPidRequest.fetch_metadata(self)

        time_key = "#{data.request_id}-service" |> String.to_atom

        data
        |> RequestMetadata.add_time(time_key, 5)
        |> (fn (data) -> MetaPidRequest.put_metadata(self, data) end).()

        {:ok, data} = MetaPidRequest.fetch_metadata(self)

        MetaPidRequest.PlugTest.ResultsServer.report_results(data)

        conn
      end

      def respond(conn, _) do
        conn |> send_resp(200, "ok")
      end
    end

    setup do
      {:ok, _} = Plug.Adapters.Cowboy.http(Scenario2, [], [ref: :scenario2])

      on_exit fn () ->
        Plug.Adapters.Cowboy.shutdown(:scenario2)
      end

      :ok
    end

    test "handles several concurrent connections each with a synchronous operation" do
      tasks = Enum.map(0..9, fn (_) ->
        Task.async(fn () ->
          HTTPoison.get!("http://localhost:4000")
        end)
      end)

      _ = tasks |> Task.yield_many()

      results = ResultsServer.get_results()

      assert results |> Enum.count == 10
    end
  end
end
