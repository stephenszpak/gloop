defmodule RealityAnchorWeb.OptionalAuthPipeline do
  @moduledoc """
  Optional authentication pipeline that allows both authenticated and guest users.
  Sets current_user to nil for guest users.
  """
  
  use Guardian.Plug.Pipeline, otp_app: :reality_anchor,
                              module: RealityAnchor.Guardian,
                              error_handler: RealityAnchorWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end