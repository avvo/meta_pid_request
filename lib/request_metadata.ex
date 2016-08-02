defmodule RequestMetadata do
  defstruct request_id: nil, start_time: nil, times: %{}

  @type t :: RequestMetadata

  @spec add_time(RequestMetadata.t, atom, number) :: RequestMetadata.t
  def add_time(metadata, key, value) do
    existing  = Map.get(metadata.times, key, [])
    new_times = Map.put(metadata.times, key, [value | existing])

    %{metadata | times: new_times}
  end
end
