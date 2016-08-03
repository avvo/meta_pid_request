defmodule MetaPidRequestTest do
  use ExUnit.Case

  doctest MetaPidRequest

  setup do
    pid = MetaPidRequest.start_link()

    %{server: pid}
  end
end
