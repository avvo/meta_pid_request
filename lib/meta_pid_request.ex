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
    Registry.put_pid(pid, metadata)
  end

  @spec fetch_metadata(pid()) :: {:ok, RequestMetadata.t} | :error
  def fetch_metadata(pid) do
    Registry.fetch_pid(pid)
  end

  @spec add_time(pid(), atom(), number) :: atom()
  def add_time(pid, key, value) do
    Registry.transform_pid(pid, fn (metadata) ->
      RequestMetadata.add_time(metadata, key, value)
    end)
  end
end
