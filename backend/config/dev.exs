import Config

# Configure your database
config :reality_anchor, RealityAnchor.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "reality_anchor_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
config :reality_anchor, RealityAnchorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "your_dev_secret_key_base_here",
  watchers: []

# Enable dev routes for dashboard and mailbox
config :reality_anchor, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable Swoosh Local Adapter in development
config :swoosh, :api_client, false

# Guardian development config
config :reality_anchor, RealityAnchor.Guardian,
  secret_key: "dev_guardian_secret_key_change_in_prod"