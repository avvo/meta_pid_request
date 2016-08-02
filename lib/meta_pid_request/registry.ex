defmodule MetaPidRequest.Registry do
  use MetaPid, into: MetaPidRequest.RequestMetadata, name: :meta_pid_request
end
