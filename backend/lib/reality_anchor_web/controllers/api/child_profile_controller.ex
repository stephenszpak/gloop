defmodule RealityAnchorWeb.API.ChildProfileController do
  use RealityAnchorWeb, :controller
  
  alias RealityAnchor.{Accounts, Missions, Guardian}

  action_fallback RealityAnchorWeb.FallbackController

  @doc """
  GET /api/v1/child_profiles
  List all child profiles for current user
  """
  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    child_profiles = Accounts.list_child_profiles_for_user(user.id)
    
    render(conn, :index, %{child_profiles: child_profiles})
  end

  @doc """
  POST /api/v1/child_profiles  
  Create a new child profile
  """
  def create(conn, %{"child_profile" => child_profile_params}) do
    user = Guardian.Plug.current_resource(conn)
    
    child_profile_params = Map.put(child_profile_params, "user_id", user.id)
    
    case Accounts.create_child_profile(child_profile_params) do
      {:ok, child_profile} ->
        conn
        |> put_status(:created)
        |> render(:show, %{child_profile: child_profile})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, %{changeset: changeset})
    end
  end

  @doc """
  GET /api/v1/child_profiles/:id
  Show a specific child profile
  """
  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    child_profile = Accounts.get_child_profile_for_user!(user.id, id)
    
    render(conn, :show, %{child_profile: child_profile})
  end

  @doc """
  PUT /api/v1/child_profiles/:id
  Update a child profile
  """
  def update(conn, %{"id" => id, "child_profile" => child_profile_params}) do
    user = Guardian.Plug.current_resource(conn)
    child_profile = Accounts.get_child_profile_for_user!(user.id, id)

    case Accounts.update_child_profile(child_profile, child_profile_params) do
      {:ok, child_profile} ->
        render(conn, :show, %{child_profile: child_profile})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, %{changeset: changeset})
    end
  end

  @doc """
  DELETE /api/v1/child_profiles/:id
  Delete a child profile
  """
  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    child_profile = Accounts.get_child_profile_for_user!(user.id, id)
    
    {:ok, _child_profile} = Accounts.delete_child_profile(child_profile)

    send_resp(conn, :no_content, "")
  end

  @doc """
  GET /api/v1/child_profiles/:id/progress
  Get progress statistics for a child
  """
  def progress(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    child_profile = Accounts.get_child_profile_for_user!(user.id, id)
    progress = Missions.get_child_progress(child_profile.id)
    
    render(conn, :progress, %{child_profile: child_profile, progress: progress})
  end

  @doc """
  GET /api/v1/child_profiles/:id/recent_submissions
  Get recent mission submissions for a child
  """
  def recent_submissions(conn, %{"id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    child_profile = Accounts.get_child_profile_for_user!(user.id, id)
    
    limit = Map.get(params, "limit", "10") |> String.to_integer()
    submissions = Missions.get_recent_submissions(child_profile.id, limit)
    
    render(conn, :recent_submissions, %{child_profile: child_profile, submissions: submissions})
  end

  @doc """
  POST /api/v1/guest/child_profiles
  Create a temporary guest child profile (no database record)
  """
  def create_guest(conn, %{"child_profile" => child_profile_params}) do
    # Create a fake child profile for guest users
    fake_child_profile = %{
      id: "guest_#{:rand.uniform(1000000)}",
      name: Map.get(child_profile_params, "name", "Guest Player"),
      age: Map.get(child_profile_params, "age", 6),
      avatar_emoji: Map.get(child_profile_params, "avatar_emoji", "😊"),
      guest_session: true
    }
    
    conn
    |> put_status(:created)
    |> render(:guest_profile, %{child_profile: fake_child_profile})
  end

  @doc """
  GET /api/v1/guest/child_profiles/:id/progress
  Get guest progress (returns default values since no data is stored)
  """
  def guest_progress(conn, %{"id" => _id}) do
    # Return default progress for guest users
    fake_progress = %{
      accuracy: 0.0,
      current_streak: 0,
      total_missions: 0,
      correct_missions: 0,
      daily_progress: %{},
      guest_session: true
    }
    
    fake_child_profile = %{
      id: "guest_session",
      name: "Guest Player",
      guest_session: true
    }
    
    render(conn, :guest_progress, %{child_profile: fake_child_profile, progress: fake_progress})
  end
end