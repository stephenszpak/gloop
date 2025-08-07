import Config

# TODO: Configure your production database
config :reality_anchor, RealityAnchor.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  socket_options: [:inet6]

# TODO: Configure your production endpoint
config :reality_anchor, RealityAnchorWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST") || "example.com", port: 443, scheme: "https"],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: secret_key_base

# Do not print debug messages in production
config :logger, level: :info

# Guardian production config - MUST be set via environment variables
config :reality_anchor, RealityAnchor.Guardian,
  secret_key: System.get_env("GUARDIAN_SECRET_KEY") || raise("GUARDIAN_SECRET_KEY not set!")

# Runtime production config will be loaded in releases.exs