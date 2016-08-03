defmodule MetaPidRequest.Plug do
  alias Plug.Conn
  @behaviour Plug

  def init(opts), do: opts

  require Logger

  @spec call(Conn.t, Plug.opts) :: Conn.t
  def call(conn, _options) do
    [request_id | _] = Conn.get_resp_header(conn, "x-request-id")

    MetaPidRequest.register_request(self, request_id)

    conn
  end
end
