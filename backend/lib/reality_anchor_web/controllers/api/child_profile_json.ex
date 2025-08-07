defmodule RealityAnchorWeb.API.ChildProfileJSON do
  alias RealityAnchor.Accounts.ChildProfile

  @doc """
  Renders a list of child_profiles.
  """
  def index(%{child_profiles: child_profiles}) do
    %{data: for(child_profile <- child_profiles, do: data(child_profile))}
  end

  @doc """
  Renders a single child_profile.
  """
  def show(%{child_profile: child_profile}) do
    %{data: data(child_profile)}
  end

  @doc """
  Renders child progress statistics
  """
  def progress(%{child_profile: child_profile, progress: progress}) do
    %{
      data: %{
        child_profile: data(child_profile),
        progress: %{
          accuracy: progress.accuracy,
          current_streak: progress.current_streak,
          total_missions: progress.total_missions,
          correct_missions: progress.correct_missions,
          daily_progress: progress.daily_progress
        }
      }
    }
  end

  @doc """
  Renders recent submissions for a child
  """
  def recent_submissions(%{child_profile: child_profile, submissions: submissions}) do
    %{
      data: %{
        child_profile: data(child_profile),
        recent_submissions: for(submission <- submissions, do: submission_data(submission))
      }
    }
  end

  @doc """
  Renders guest child profile (no database record)
  """
  def guest_profile(%{child_profile: child_profile}) do
    %{
      data: %{
        id: child_profile.id,
        name: child_profile.name,
        avatar_emoji: child_profile.avatar_emoji,
        age: child_profile.age,
        guest_session: true
      }
    }
  end

  @doc """
  Renders guest progress (default values)
  """
  def guest_progress(%{child_profile: child_profile, progress: progress}) do
    %{
      data: %{
        child_profile: %{
          id: child_profile.id,
          name: child_profile.name,
          guest_session: true
        },
        progress: %{
          accuracy: progress.accuracy,
          current_streak: progress.current_streak,
          total_missions: progress.total_missions,
          correct_missions: progress.correct_missions,
          daily_progress: progress.daily_progress,
          guest_session: true
        }
      }
    }
  end

  @doc """
  Renders validation errors
  """
  def errors(%{changeset: changeset}) do
    %{error: %{message: "Validation failed", details: translate_errors(changeset)}}
  end

  defp data(%ChildProfile{} = child_profile) do
    %{
      id: child_profile.id,
      name: child_profile.name,
      avatar_emoji: child_profile.avatar_emoji,
      birth_year: child_profile.birth_year,
      age: ChildProfile.age(child_profile),
      inserted_at: child_profile.inserted_at,
      updated_at: child_profile.updated_at
    }
  end

  defp submission_data(submission) do
    %{
      id: submission.id,
      selected_answer: submission.selected_answer,
      is_correct: submission.is_correct,
      time_spent_ms: submission.time_spent_ms,
      inserted_at: submission.inserted_at,
      mission: %{
        id: submission.mission.id,
        title: submission.mission.title,
        type: submission.mission.type,
        difficulty_level: submission.mission.difficulty_level
      }
    }
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end