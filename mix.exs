defmodule MetaPidRequest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :meta_pid_request,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"],
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      version: "0.1.0"
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
      {:plug, "~> 1.0"},

      # NON-PRODUCTION DEPS
      {:dialyxir, "~> 0.4", only: [:dev, :test]}
    ]
  end
end
