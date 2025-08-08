defmodule RealityAnchorWeb.Router do
  use RealityAnchorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug RealityAnchorWeb.AuthPipeline
  end

  pipeline :optional_auth do
    plug RealityAnchorWeb.OptionalAuthPipeline
  end

  # Public API routes (no auth required)
  scope "/api/v1", RealityAnchorWeb.API, as: :api do
    pipe_through :api

    # Authentication
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    
    # Health check
    get "/health", HealthController, :check
  end

  # Optional auth API routes (work for both authenticated and guest users)
  scope "/api/v1", RealityAnchorWeb.API, as: :api do
    pipe_through [:api, :optional_auth]

    # Missions (work for both auth and guest users)
    get "/missions/next", MissionController, :next
    post "/missions/:id/submit", MissionController, :submit
    resources "/missions", MissionController, only: [:index, :show]

    # Silly Thing Game Challenges (only endpoints requested in original spec)
    get "/silly_challenges/random", SillyChallengeController, :random
    get "/silly_challenges/:id", SillyChallengeController, :show
    post "/silly_challenges/:id/submit", SillyChallengeController, :submit

    # Guest child profiles
    post "/guest/child_profiles", ChildProfileController, :create_guest
    get "/guest/child_profiles/:id/progress", ChildProfileController, :guest_progress
  end

  # Protected API routes (auth required)
  scope "/api/v1", RealityAnchorWeb.API, as: :api do
    pipe_through [:api, :auth]

    # User profile
    get "/auth/me", AuthController, :me
    post "/auth/logout", AuthController, :logout

    # Child profiles (authenticated users only)
    resources "/child_profiles", ChildProfileController, except: [:new, :edit] do
      get "/progress", ChildProfileController, :progress
      get "/recent_submissions", ChildProfileController, :recent_submissions
    end
  end

  # Serve static images and proxy external images
  scope "/" do
    pipe_through :api
    get "/images/*path", RealityAnchorWeb.ImageController, :images
    get "/proxy-image", RealityAnchorWeb.ImageController, :proxy
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:reality_anchor, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: RealityAnchorWeb.Telemetry
    end
  end
end