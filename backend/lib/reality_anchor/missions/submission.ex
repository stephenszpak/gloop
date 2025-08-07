defmodule RealityAnchor.Missions.Submission do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias RealityAnchor.Accounts.ChildProfile
  alias RealityAnchor.Missions.Mission

  schema "submissions" do
    field :selected_answer, :boolean
    field :is_correct, :boolean
    field :time_spent_ms, :integer, default: 0
    
    belongs_to :child_profile, ChildProfile
    belongs_to :mission, Mission

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:selected_answer, :is_correct, :time_spent_ms, :child_profile_id, :mission_id])
    |> validate_required([:selected_answer, :is_correct, :child_profile_id, :mission_id])
    |> validate_number(:time_spent_ms, greater_than_or_equal_to: 0)
    |> unique_constraint([:child_profile_id, :mission_id], 
         message: "Child has already completed this mission")
    |> foreign_key_constraint(:child_profile_id)
    |> foreign_key_constraint(:mission_id)
  end

  @doc """
  Create changeset with automatic correctness calculation
  """
  def create_changeset(attrs, %Mission{} = mission) do
    selected_answer = Map.get(attrs, :selected_answer) || Map.get(attrs, "selected_answer")
    is_correct = calculate_correctness(selected_answer, mission)
    
    clean_attrs = %{
      child_profile_id: Map.get(attrs, :child_profile_id),
      mission_id: Map.get(attrs, :mission_id),
      selected_answer: selected_answer,
      time_spent_ms: Map.get(attrs, :time_spent_ms, 0),
      is_correct: is_correct
    }
    
    %__MODULE__{}
    |> changeset(clean_attrs)
  end

  defp calculate_correctness(selected_answer, %Mission{type: "spot_the_silly_thing", choices: choices}) when is_list(choices) do
    # For spot_the_silly_thing, find the correct choice and compare IDs
    case Enum.find(choices, fn choice -> Map.get(choice, "is_correct") == true end) do
      %{"id" => correct_id} -> selected_answer == correct_id
      _ -> false
    end
  end

  defp calculate_correctness(selected_answer, %Mission{type: "match_sound_to_image", choices: choices}) when is_list(choices) do
    # For match_sound_to_image, find the correct choice and compare IDs  
    case Enum.find(choices, fn choice -> Map.get(choice, "is_correct") == true end) do
      %{"id" => correct_id} -> selected_answer == correct_id
      _ -> false
    end
  end

  defp calculate_correctness(selected_answer, %Mission{correct_answer: correct_answer}) do
    # For traditional missions, compare directly
    selected_answer == correct_answer
  end

  @doc """
  Get submission accuracy percentage for a child
  """
  def accuracy_for_child(child_profile_id) do
    import Ecto.Query
    
    query = from s in __MODULE__,
            where: s.child_profile_id == ^child_profile_id,
            select: {count(s.id), sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", s.is_correct))}
    
    case RealityAnchor.Repo.one(query) do
      {total, correct} when total > 0 ->
        (correct / total * 100) |> Float.round(1)
      _ -> 0.0
    end
  end

  @doc """
  Get current streak for a child (consecutive correct answers)
  """
  def current_streak_for_child(child_profile_id) do
    import Ecto.Query
    
    # Get recent submissions in reverse chronological order
    recent_submissions = 
      from s in __MODULE__,
      where: s.child_profile_id == ^child_profile_id,
      order_by: [desc: s.inserted_at],
      limit: 50,
      select: s.is_correct
    
    RealityAnchor.Repo.all(recent_submissions)
    |> count_streak_from_recent()
  end

  defp count_streak_from_recent([]), do: 0
  defp count_streak_from_recent([true | rest]) do
    1 + count_streak_from_recent(rest)
  end
  defp count_streak_from_recent([false | _]), do: 0

  @doc """
  Get daily progress for a child (missions completed each day)
  """
  def daily_progress_for_child(child_profile_id, days_back \\ 7) do
    import Ecto.Query
    
    cutoff_date = Date.utc_today() |> Date.add(-days_back)
    
    from s in __MODULE__,
    where: s.child_profile_id == ^child_profile_id 
           and fragment("?::date", s.inserted_at) >= ^cutoff_date,
    group_by: fragment("?::date", s.inserted_at),
    select: {fragment("?::date", s.inserted_at), count(s.id)},
    order_by: [asc: fragment("?::date", s.inserted_at)]
  end
end