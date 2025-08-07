import Config

# Configure your database
config :reality_anchor, RealityAnchor.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "reality_anchor_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test
config :reality_anchor, RealityAnchorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "your_test_secret_key_base_here",
  server: false

# In test we don't send emails.
config :swoosh, :api_client, false

# Disable logging below warning level
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Guardian test config
config :reality_anchor, RealityAnchor.Guardian,
  secret_key: "test_guardian_secret_key"

# Speed up password hashing in tests
config :bcrypt_elixir, :log_rounds, 1