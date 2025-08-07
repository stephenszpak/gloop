defmodule RealityAnchorWeb.API.MissionJSON do
  alias RealityAnchor.Missions.Mission

  @doc """
  Renders a list of missions.
  """
  def index(%{missions: missions}) do
    %{data: for(mission <- missions, do: data(mission))}
  end

  @doc """
  Renders a single mission.
  """
  def show(%{mission: mission}) do
    %{data: data(mission)}
  end

  @doc """
  Renders submission result with mission feedback
  """
  def submission_result(%{submission: submission, mission: mission}) do
    %{
      data: %{
        submission: %{
          id: submission.id,
          selected_answer: submission.selected_answer,
          is_correct: submission.is_correct,
          time_spent_ms: submission.time_spent_ms,
          inserted_at: submission.inserted_at
        },
        mission: %{
          id: mission.id,
          title: mission.title,
          type: mission.type,
          correct_answer: mission.correct_answer,
          explanation: mission.explanation,
          explanation_audio_url: mission.explanation_audio_url,
          difficulty_level: mission.difficulty_level
        },
        result: %{
          is_correct: submission.is_correct,
          explanation: mission.explanation
        }
      }
    }
  end

  @doc """
  Renders guest submission result (no database record)
  """
  def guest_submission_result(%{submission: submission, mission: mission}) do
    %{
      data: %{
        submission: %{
          selected_answer: submission.selected_answer,
          is_correct: submission.is_correct,
          time_spent_ms: submission.time_spent_ms,
          guest_session: true
        },
        mission: %{
          id: mission.id,
          title: mission.title,
          type: mission.type,
          correct_answer: mission.correct_answer,
          explanation: mission.explanation,
          explanation_audio_url: mission.explanation_audio_url,
          difficulty_level: mission.difficulty_level
        },
        result: %{
          is_correct: submission.is_correct,
          explanation: mission.explanation
        }
      }
    }
  end

  @doc """
  Renders error message
  """
  def error(%{message: message}) do
    %{error: %{message: message}}
  end

  @doc """
  Renders validation errors
  """
  def errors(%{changeset: changeset}) do
    %{error: %{message: "Validation failed", details: translate_errors(changeset)}}
  end

  defp data(%Mission{} = mission) do
    %{
      id: mission.id,
      title: mission.title,
      type: mission.type,
      image_url: mission.image_url,
      content_url: mission.content_url,
      audio_url: mission.audio_url,
      question_text: mission.question_text,
      difficulty_level: mission.difficulty_level,
      tags: mission.tags,
      # Pre-reader mission fields
      prompt_audio_url: mission.prompt_audio_url,
      emoji_hint: mission.emoji_hint,
      choices: mission.choices,
      created_by_ai: mission.created_by_ai,
      # Note: We don't expose correct_answer and explanation until after submission
      inserted_at: mission.inserted_at
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