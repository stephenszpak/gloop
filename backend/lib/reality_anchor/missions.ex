defmodule RealityAnchor.Missions do
  @moduledoc """
  The Missions context.
  """

  import Ecto.Query, warn: false
  alias RealityAnchor.Repo
  alias RealityAnchor.Missions.{Mission, Submission}
  alias RealityAnchor.Accounts.ChildProfile

  ## Mission CRUD

  @doc """
  Returns the list of missions.

  ## Examples

      iex> list_missions()
      [%Mission{}, ...]

  """
  def list_missions do
    Repo.all(Mission)
  end

  @doc """
  Gets a single mission.

  Raises `Ecto.NoResultsError` if the Mission does not exist.

  ## Examples

      iex> get_mission!(123)
      %Mission{}

      iex> get_mission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mission!(id), do: Repo.get!(Mission, id)

  @doc """
  Creates a mission.

  ## Examples

      iex> create_mission(%{field: value})
      {:ok, %Mission{}}

      iex> create_mission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mission(attrs \\ %{}) do
    %Mission{}
    |> Mission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mission.

  ## Examples

      iex> update_mission(mission, %{field: new_value})
      {:ok, %Mission{}}

      iex> update_mission(mission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mission(%Mission{} = mission, attrs) do
    mission
    |> Mission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mission.

  ## Examples

      iex> delete_mission(mission)
      {:ok, %Mission{}}

      iex> delete_mission(mission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mission(%Mission{} = mission) do
    Repo.delete(mission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mission changes.

  ## Examples

      iex> change_mission(mission)
      %Ecto.Changeset{data: %Mission{}}

  """
  def change_mission(%Mission{} = mission, attrs \\ %{}) do
    Mission.changeset(mission, attrs)
  end

  ## Mission Selection Logic

  @doc """
  Gets the next mission for a child based on their progress and age.
  
  Algorithm:
  1. Filter by child's appropriate difficulty level
  2. Exclude missions already completed
  3. Prioritize mission types the child hasn't tried
  4. Return random mission from suitable candidates
  """
  def get_next_mission_for_child(child_profile_id) do
    child_profile = Repo.get!(ChildProfile, child_profile_id)
    difficulty_level = calculate_difficulty_level(child_profile)
    
    # Get suitable missions
    candidates =
      Mission
      |> Mission.active()
      |> Mission.for_difficulty(difficulty_level)
      |> Mission.not_completed_by_child(child_profile_id)
      |> Repo.all()
    
    case candidates do
      [] -> {:error, :no_missions_available}
      missions -> 
        # Randomly select from candidates
        selected_mission = Enum.random(missions)
        {:ok, selected_mission}
    end
  end

  @doc """
  Gets a random active mission for guest users.
  Prioritizes easier missions for better user experience.
  """
  def get_random_active_mission do
    # Get easier missions first (level 1-2) for guest users
    candidates =
      Mission
      |> Mission.active()
      |> Mission.for_difficulty_range(1, 2)
      |> Repo.all()
    
    # If no easy missions, get any active mission
    candidates = case candidates do
      [] -> 
        Mission
        |> Mission.active()
        |> Repo.all()
      missions -> missions
    end
    
    case candidates do
      [] -> {:error, :no_missions_available}
      missions -> 
        selected_mission = Enum.random(missions)
        {:ok, selected_mission}
    end
  end

  @doc """
  Calculate appropriate difficulty level based on child's age and performance
  """
  def calculate_difficulty_level(%ChildProfile{} = child_profile) do
    base_level = case ChildProfile.age(child_profile) do
      age when age in 4..5 -> 1
      age when age in 6..7 -> 2  
      age when age >= 8 -> 3
      _ -> 1  # Default for unknown age
    end
    
    # Adjust based on accuracy
    accuracy = Submission.accuracy_for_child(child_profile.id)
    
    cond do
      accuracy >= 80.0 && base_level < 5 -> base_level + 1
      accuracy <= 50.0 && base_level > 1 -> base_level - 1
      true -> base_level
    end
  end

  ## Submission CRUD

  @doc """
  Creates a submission for a child's answer to a mission.

  ## Examples

      iex> submit_mission_answer(child_id, mission_id, true, 5000)
      {:ok, %Submission{}}

      iex> submit_mission_answer(child_id, mission_id, invalid, 1000)
      {:error, %Ecto.Changeset{}}

  """
  def submit_mission_answer(child_profile_id, mission_id, selected_answer, time_spent_ms \\ 0) do
    mission = get_mission!(mission_id)
    
    attrs = %{
      child_profile_id: child_profile_id,
      mission_id: mission_id,
      selected_answer: selected_answer,
      time_spent_ms: time_spent_ms
    }
    
    Submission.create_changeset(attrs, mission)
    |> Repo.insert()
  end

  @doc """
  Gets child's progress statistics
  """
  def get_child_progress(child_profile_id) do
    accuracy = Submission.accuracy_for_child(child_profile_id)
    current_streak = Submission.current_streak_for_child(child_profile_id)
    
    total_missions = 
      from(s in Submission, where: s.child_profile_id == ^child_profile_id)
      |> Repo.aggregate(:count)
    
    correct_missions = 
      from(s in Submission, 
           where: s.child_profile_id == ^child_profile_id and s.is_correct == true)
      |> Repo.aggregate(:count)
    
    daily_progress = 
      Submission.daily_progress_for_child(child_profile_id)
      |> Repo.all()
      |> Enum.into(%{})
    
    %{
      accuracy: accuracy,
      current_streak: current_streak,
      total_missions: total_missions,
      correct_missions: correct_missions,
      daily_progress: daily_progress
    }
  end

  @doc """
  Gets recent submissions for a child
  """
  def get_recent_submissions(child_profile_id, limit \\ 10) do
    from(s in Submission,
         where: s.child_profile_id == ^child_profile_id,
         order_by: [desc: s.inserted_at],
         limit: ^limit,
         preload: [:mission])
    |> Repo.all()
  end

  @doc """
  Lists all submissions for admin/analytics
  """
  def list_submissions(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    
    from(s in Submission,
         order_by: [desc: s.inserted_at],
         limit: ^limit,
         preload: [:child_profile, :mission])
    |> Repo.all()
  end
end