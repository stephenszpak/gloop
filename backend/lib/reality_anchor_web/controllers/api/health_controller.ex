defmodule RealityAnchorWeb.API.HealthController do
  use RealityAnchorWeb, :controller

  @doc """
  GET /api/v1/health
  Basic health check endpoint
  """
  def check(conn, _params) do
    # Check database connection
    db_status = try do
      RealityAnchor.Repo.query!("SELECT 1")
      "ok"
    rescue
      _ -> "error"
    end

    conn
    |> put_status(:ok)
    |> json(%{
      status: "ok",
      timestamp: DateTime.utc_now(),
      version: "1.0.0",
      database: db_status
    })
  end
end