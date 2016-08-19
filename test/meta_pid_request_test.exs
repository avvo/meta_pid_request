defmodule MetaPidRequestTest do
  use ExUnit.Case
  alias MetaPidRequest.RequestMetadata

  doctest MetaPidRequest

  test "registers a request with a time for the passed pid" do
    MetaPidRequest.register_request(self, "asdf")

    {:ok, data} = MetaPidRequest.Registry.fetch_pid(self)

    assert is_integer(data.start_time)
    assert data.request_id == "asdf"
    assert data.times == %{}
  end

  test "retrieves a registered pid's data" do
    MetaPidRequest.register_request(self, "asdf")
    assert MetaPidRequest.Registry.fetch_pid(self) == MetaPidRequest.fetch_metadata(self)
  end

  test "retrieves a registered pid's request id if one exists" do
    MetaPidRequest.register_request(self, "asdf")
    assert MetaPidRequest.fetch_request_id(self) == "asdf"
  end

  test "returns nil if can't find metadata for passed pid" do
    assert MetaPidRequest.fetch_request_id(self) == nil
  end

  test "adds a time to the specified service list for a pid" do
    MetaPidRequest.register_request(self, "asdf")

    MetaPidRequest.add_time(self, :service1, 1)
    MetaPidRequest.add_time(self, :service1, 2)
    MetaPidRequest.add_time(self, :service1, 3)
    MetaPidRequest.add_time(self, :service2, 1)

    {:ok, %RequestMetadata{times: times}} = MetaPidRequest.fetch_metadata(self)

    assert times == %{service1: [3,2,1], service2: [1]}
  end
end
