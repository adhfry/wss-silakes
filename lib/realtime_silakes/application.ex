defmodule RealtimeSilakes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RealtimeSilakesWeb.Telemetry,
      RealtimeSilakes.Repo,
      {DNSCluster, query: Application.get_env(:realtime_silakes, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RealtimeSilakes.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RealtimeSilakes.Finch},
      # Start a worker by calling: RealtimeSilakes.Worker.start_link(arg)
      # {RealtimeSilakes.Worker, arg},
      # Start to serve requests, typically the last entry
      RealtimeSilakesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RealtimeSilakes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RealtimeSilakesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
