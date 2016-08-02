defmodule MetaPidRequestTest do
  use ExUnit.Case

  doctest MetaPidRequest

  setup do
    pid = MetaPidRequest.start_link()

    %{server: pid}
  end

  test "inserts fetches data for the right group leader" do
    parent = self()

    pid = spawn(fn () ->
      Process.group_leader(self, parent)
      receive do
        _ -> nil
      end
    end)

    MetaPidRequest.register_request(self, "asdf")

    assert MetaPidRequest.fetch_metadata(pid) == MetaPidRequest.fetch_metadata(self)
  end
end
