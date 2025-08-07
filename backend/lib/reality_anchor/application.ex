defmodule RealityAnchor.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RealityAnchorWeb.Telemetry,
      RealityAnchor.Repo,
      {DNSCluster, query: Application.get_env(:reality_anchor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RealityAnchor.PubSub},
      {Finch, name: RealityAnchor.Finch},
      RealityAnchorWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: RealityAnchor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    RealityAnchorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end