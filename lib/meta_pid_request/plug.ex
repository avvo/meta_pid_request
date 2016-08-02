defmodule MetaPidRequest.Plug do
  alias Plug.Conn
  @behaviour Plug

  def init(opts), do: opts

  @spec call(Conn.t, Plug.opts) :: Conn.t
  def call(conn, header) do
    [request_id | _] = Conn.get_req_header(conn, "x-request-id")

    MetaPidRequest.register_request(self, request_id)

    conn
  end
end
