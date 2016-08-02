defmodule MetaPidRequest.Plug do
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :http_header, "x-request-id")
  end

  def call(conn, header) do
    [request_id | _] = Conn.get_req_header(conn, header)

    MetaPidRequest.register_request(self, request_id)

    conn
  end
end
