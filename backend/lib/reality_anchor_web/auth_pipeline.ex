defmodule RealityAnchorWeb.AuthPipeline do
  use Guardian.Plug.Pipeline, 
    otp_app: :reality_anchor,
    module: RealityAnchor.Guardian,
    error_handler: RealityAnchorWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end

defmodule RealityAnchorWeb.OptionalAuthPipeline do
  use Guardian.Plug.Pipeline, 
    otp_app: :reality_anchor,
    module: RealityAnchor.Guardian,
    error_handler: RealityAnchorWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end

defmodule RealityAnchorWeb.AuthErrorHandler do
  @moduledoc """
  Guardian error handler for API authentication errors
  """
  
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]
  
  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    message = case type do
      :invalid_token -> "Invalid token"
      :unauthenticated -> "Authentication required"
      :no_resource_found -> "User not found"
      :already_authenticated -> "Already authenticated"
      :not_authenticated -> "Not authenticated"
      _ -> "Authentication error"
    end

    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: message, type: type}})
  end
end