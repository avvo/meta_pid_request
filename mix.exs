defmodule MetaPidRequest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :meta_pid_request,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: description(),
      dialyzer: [
        plt_add_deps: :transitive,
        plt_file: {:no_warn, ".local.plt"}
      ],
      elixir: "~> 1.4",
      package: package(),
      start_permanent: Mix.env == :prod,
      version: "0.2.1"
    ]
  end

  def application do
    [
      applications: [:logger, :plug],
      mod: {MetaPidRequest, []}
    ]
  end

  defp deps do
    [
      {:meta_pid, "~> 0.2"},
      {:plug, "~> 1.3"},

      # NON-PRODUCTION DEPS
      {:dialyxir, "~> 0.5", only: [:dev, :test]}
    ]
  end

  def description do
    """
    MetaPidRequest provides an OTP application for keeping track of meta data associated with requests.
    """
  end

  defp package do
    [
      name: :meta_pid_request,
      maintainers: ["Avvo, Inc", "Donald Plummer"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/avvo/meta_pid_request"
      }
    ]
  end
end
