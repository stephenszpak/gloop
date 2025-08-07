import Config

config :reality_anchor,
  ecto_repos: [RealityAnchor.Repo]

config :reality_anchor, RealityAnchorWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: RealityAnchorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RealityAnchor.PubSub,
  live_view: [signing_salt: "reality_anchor_salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Guardian JWT Configuration
config :reality_anchor, RealityAnchor.Guardian,
  issuer: "reality_anchor",
  secret_key: "your_guardian_secret_key_here", # TODO: Move to runtime config
  ttl: {30, :days}

# Swoosh API client is used for development and production
config :swoosh, :api_client, Swoosh.ApiClient.Finch

config :finch, :default, pools: %{:default => [size: 10]}

# Import environment specific config
import_config "#{config_env()}.exs"