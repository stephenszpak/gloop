defmodule RealityAnchorWeb.API.MissionController do
  use RealityAnchorWeb, :controller
  
  alias RealityAnchor.{Accounts, Missions, Guardian}
  alias RealityAnchor.Missions.Mission

  action_fallback RealityAnchorWeb.FallbackController

  @doc """
  GET /api/v1/missions/next?child_id=:child_id (optional)
  Get next mission for a specific child or random mission for guest
  """
  def next(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    child_id = Map.get(params, "child_id")
    
    case {user, child_id} do
      # Authenticated user with child_id
      {%Accounts.User{} = user, child_id} when not is_nil(child_id) ->
        child_profile = Accounts.get_child_profile_for_user!(user.id, child_id)
        get_mission_for_child(conn, child_profile.id)
        
      # Guest user or no child_id provided - return random mission
      _ ->
        get_random_mission(conn)
    end
  end
  
  defp get_mission_for_child(conn, child_profile_id) do
    case Missions.get_next_mission_for_child(child_profile_id) do
      {:ok, mission} ->
        render(conn, :show, %{mission: mission})
        
      {:error, :no_missions_available} ->
        conn
        |> put_status(:not_found)
        |> render(:error, %{message: "No missions available for this child"})
    end
  end
  
  defp get_random_mission(conn) do
    case Missions.get_random_active_mission() do
      {:ok, mission} ->
        render(conn, :show, %{mission: mission})
        
      {:error, :no_missions_available} ->
        conn
        |> put_status(:not_found)
        |> render(:error, %{message: "No missions available"})
    end
  end

  @doc """
  POST /api/v1/missions/:id/submit
  Submit answer for a mission
  
  Body: {
    "child_id": "123",
    "selected_answer": true,
    "time_spent_ms": 5000
  }
  """
  def submit(conn, %{"id" => mission_id} = params) do
    user = Guardian.Plug.current_resource(conn)
    child_id = Map.get(params, "child_id")
    selected_answer = Map.get(params, "selected_answer")
    time_spent_ms = Map.get(params, "time_spent_ms", 0)
    
    # Verify mission exists
    mission = Missions.get_mission!(mission_id)
    
    case {user, child_id} do
      # Authenticated user with child_id
      {%Accounts.User{} = user, child_id} when not is_nil(child_id) ->
        child_profile = Accounts.get_child_profile_for_user!(user.id, child_id)
        submit_for_child(conn, child_profile.id, mission, selected_answer, time_spent_ms)
        
      # Guest user - just return result without saving
      _ ->
        submit_for_guest(conn, mission, selected_answer, time_spent_ms)
    end
  end
  
  defp submit_for_child(conn, child_profile_id, mission, selected_answer, time_spent_ms) do
    case Missions.submit_mission_answer(child_profile_id, mission.id, selected_answer, time_spent_ms) do
      {:ok, submission} ->
        submission = RealityAnchor.Repo.preload(submission, [:mission])
        
        conn
        |> put_status(:created)
        |> render(:submission_result, %{submission: submission, mission: mission})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, %{changeset: changeset})
    end
  end
  
  defp submit_for_guest(conn, mission, selected_answer, time_spent_ms) do
    # Use the same correctness calculation as the Submission module
    is_correct = calculate_guest_correctness(selected_answer, mission)
    
    # Create a temporary submission-like response without saving to DB
    fake_submission = %{
      selected_answer: selected_answer,
      is_correct: is_correct,
      time_spent_ms: time_spent_ms,
      mission: mission
    }
    
    conn
    |> put_status(:created)
    |> render(:guest_submission_result, %{submission: fake_submission, mission: mission})
  end

  defp calculate_guest_correctness(selected_answer, %Mission{type: "spot_the_silly_thing", choices: choices}) when is_list(choices) do
    # For spot_the_silly_thing, find the correct choice and compare IDs
    case Enum.find(choices, fn choice -> Map.get(choice, "is_correct") == true end) do
      %{"id" => correct_id} -> selected_answer == correct_id
      _ -> false
    end
  end

  defp calculate_guest_correctness(selected_answer, %Mission{type: "match_sound_to_image", choices: choices}) when is_list(choices) do
    # For match_sound_to_image, find the correct choice and compare IDs  
    case Enum.find(choices, fn choice -> Map.get(choice, "is_correct") == true end) do
      %{"id" => correct_id} -> selected_answer == correct_id
      _ -> false
    end
  end

  defp calculate_guest_correctness(selected_answer, %Mission{correct_answer: correct_answer}) do
    # For traditional missions, compare directly
    selected_answer == correct_answer
  end

  @doc """
  GET /api/v1/missions
  List missions (for admin/debugging - optional)
  """
  def index(conn, params) do
    # Optional: Add pagination
    limit = Map.get(params, "limit", "20") |> String.to_integer()
    type = Map.get(params, "type")
    
    missions = 
      RealityAnchor.Missions.Mission
      |> then(fn query ->
        if type, do: RealityAnchor.Missions.Mission.of_type(query, type), else: query
      end)
      |> RealityAnchor.Missions.Mission.active()
      |> RealityAnchor.Repo.all()
      |> Enum.take(limit)
    
    render(conn, :index, %{missions: missions})
  end

  @doc """
  GET /api/v1/missions/:id
  Show a specific mission (for admin/debugging)  
  """
  def show(conn, %{"id" => id}) do
    mission = Missions.get_mission!(id)
    render(conn, :show, %{mission: mission})
  end
end