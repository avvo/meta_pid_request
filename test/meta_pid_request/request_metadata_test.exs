defmodule MetaPidRequest.RequestMetadataTest do
  use ExUnit.Case, async: true
  doctest MetaPidRequest.RequestMetadata

  alias MetaPidRequest.RequestMetadata

  test "can be initialized without specific times" do
    structure = %RequestMetadata{
      request_id: "asdf",
      start_time: 0
    }
    assert structure.request_id == "asdf"
    assert structure.start_time == 0
    assert structure.times == %{}
  end

  test "can be initialized with specific times" do
    structure = %RequestMetadata{
      times: %{
        service1: [],
        service2: [],
        db: []
      }
    }

    assert structure.times == %{service1: [], service2: [], db: []}
  end

  test "can add a new time for an existing service" do
    structure = %RequestMetadata{
      request_id: 12345,
      start_time: 4444,
      times: %{
        service1: [1, 2, 3]
      }
    }

    result = structure |> RequestMetadata.add_time(:service1, 1234)

    assert result.request_id == 12345
    assert result.start_time == 4444
    assert Map.get(result.times, :service1) == [1234, 1, 2, 3]
  end

  test "can add a time for a service that doesn't exist yet" do
    structure = %RequestMetadata{
      request_id: 12345,
      start_time: 4444,
      times: %{}
    }

    result = structure |> RequestMetadata.add_time(:service1, 1234)

    assert result.request_id == 12345
    assert result.start_time == 4444
    assert Map.get(result.times, :service1) == [1234]
  end
end
