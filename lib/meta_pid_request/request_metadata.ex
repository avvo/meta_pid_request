defmodule MetaPidRequest.RequestMetadata do
  @type t :: %__MODULE__{
    request_id: String.t | nil,
    start_time: integer() | nil,
    times:      %{atom() => list(number)}
  }
  defstruct request_id: nil, start_time: nil, times: %{}

  @spec add_time(t, atom(), number()) :: t
  def add_time(metadata, key, value) do
    existing  = Map.get(metadata.times, key, [])
    new_times = Map.put(metadata.times, key, [value | existing])

    %{metadata | times: new_times}
  end
end
