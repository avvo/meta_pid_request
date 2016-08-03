# MetaPidRequest

MetaPidRequest provides an OTP application for keeping
track of meta data associated with requests.

It exposes a simple %{pid => metadata} KV GenServer.

MetaPidRequest can be used to keep track of request ids
and outbound service call times associated with a connection
process.

It exposes a Plug to make managing this life cycle easier.


## Installation

  1. Add `meta_pid_request` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      {:meta_pid_request, git: "git@github.com:avvo/meta_pid_request.git"}
    end
    ```

  2. Ensure `meta_pid_request` is started before your application:

    ```elixir
    def application do
      [applications: [:meta_pid_request]]
    end
    ```

  3. Use the Plug in any pipelined HTTP application to initialize entries in the registry

    ```elixir
      # works best if included after Plug.RequestId
      plug MetaPidRequest.Plug
    ```

## Use

  ```elixir
    # To register a new request to the registry
    # (this is handled automatically by the plug)
    MetaPidRequest.register_request(pid, request_id)

    # To replace data for a particular pid
    MetaPidRequest.put_metadata(pid, metadata)

    # To retrieve metadata for a pid
    MetaPidRequest.fetch_metadata(pid)

    # To add a service call time for a pid
    MetaPidRequest.add_time(pid, service_name, duration)
  ```
