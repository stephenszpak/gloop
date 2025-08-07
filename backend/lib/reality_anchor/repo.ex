defmodule RealityAnchor.Repo do
  use Ecto.Repo,
    otp_app: :reality_anchor,
    adapter: Ecto.Adapters.Postgres
end