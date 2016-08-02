defmodule MetaPidRequest do
  alias MetaPidRequest.Registry
  alias MetaPidRequest.RequestMetadata

  @spec start_link() :: {:ok, pid()} | {:error, any()}
  def start_link() do
    Registry.start_link()
  end

  @spec register_request(pid(), String.t) :: atom()
  def register_request(pid, request_id) do
    data = %RequestMetadata{
      request_id: request_id,
      start_time: System.monotonic_time()
    }

    Registry.register_pid(pid, data)
  end

  @spec put_metadata(pid(), RequestMetadata.t) :: atom()
  def put_metadata(pid, metadata) do
    Registry.put_pid(pid |> request_pid, metadata)
  end

  @spec fetch_metadata(pid()) :: {:ok, RequestMetadata.t} | :error
  def fetch_metadata(pid) do
    Registry.fetch_pid(pid |> request_pid)
  end

  @spec request_pid(pid()) :: pid()
  defp request_pid(pid) do
    registry = Registry.get_registry()

    case Map.has_key?(registry, pid) do
      true -> pid
      false -> Process.info(pid)[:group_leader]
    end
  end
end
