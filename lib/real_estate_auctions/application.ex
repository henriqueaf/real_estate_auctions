defmodule RealEstateAuctions.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RealEstateAuctionsWeb.Telemetry,
      RealEstateAuctions.Repo,
      {DNSCluster, query: Application.get_env(:real_estate_auctions, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RealEstateAuctions.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RealEstateAuctions.Finch},
      # Start a worker by calling: RealEstateAuctions.Worker.start_link(arg)
      # {RealEstateAuctions.Worker, arg},
      # Start to serve requests, typically the last entry
      RealEstateAuctionsWeb.Endpoint,

      # Custom Workers
      %{
        id: FetchAuctionsScheduler,
        start: {RealEstateAuctions.FetchAuctionsScheduler, :start, []},
        restart: :permanent,
        type: :worker
      },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RealEstateAuctions.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RealEstateAuctionsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
