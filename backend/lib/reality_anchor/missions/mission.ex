defmodule RealityAnchor.Missions.Mission do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  
  alias RealityAnchor.Missions.Submission

  @mission_types ~w(real_or_fake_image real_or_fake_story real_or_fake_video real_or_fake_news spot_the_silly_thing match_sound_to_image)

  schema "missions" do
    field :title, :string
    field :type, :string, default: "real_or_fake_image"
    field :image_url, :string
    field :content_url, :string
    field :audio_url, :string
    field :question_text, :string
    field :correct_answer, :boolean
    field :explanation, :string
    field :difficulty_level, :integer, default: 1
    field :is_active, :boolean, default: true
    field :tags, {:array, :string}, default: []
    
    # New fields for pre-reader missions
    field :prompt_audio_url, :string
    field :explanation_audio_url, :string
    field :emoji_hint, :string
    field :choices, {:array, :map}, default: []
    field :created_by_ai, :boolean, default: false
    
    has_many :submissions, Submission, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(mission, attrs) do
    mission
    |> cast(attrs, [:title, :type, :image_url, :content_url, :audio_url, :question_text, 
                    :correct_answer, :explanation, :difficulty_level, :is_active, :tags,
                    :prompt_audio_url, :explanation_audio_url, :emoji_hint, :choices, :created_by_ai])
    |> validate_required([:title, :type, :explanation])
    |> validate_inclusion(:type, @mission_types)
    |> validate_length(:title, min: 5, max: 200)
    |> validate_length(:explanation, min: 20, max: 1000)
    |> validate_number(:difficulty_level, greater_than: 0, less_than_or_equal_to: 5)
    |> validate_content_by_type()
  end

  @doc """
  Returns list of valid mission types
  """
  def mission_types, do: @mission_types

  @doc """
  Returns missions suitable for a child's age and difficulty level
  """
  def for_difficulty(query, level) when level in 1..5 do
    from(m in query, where: m.difficulty_level <= ^level)
  end

  @doc """
  Returns missions within a difficulty range (for guest users)
  """
  def for_difficulty_range(query, min_level, max_level) when min_level <= max_level do
    from(m in query, where: m.difficulty_level >= ^min_level and m.difficulty_level <= ^max_level)
  end

  @doc """
  Returns only active missions
  """
  def active(query) do
    from(m in query, where: m.is_active == true)
  end

  @doc """
  Returns missions of specific type
  """
  def of_type(query, type) when type in @mission_types do
    from(m in query, where: m.type == ^type)
  end

  @doc """
  Returns missions excluding ones already completed by child
  """
  def not_completed_by_child(query, child_profile_id) do
    completed_mission_ids = 
      from(s in Submission, 
           where: s.child_profile_id == ^child_profile_id,
           select: s.mission_id)
    
    from(m in query, where: m.id not in subquery(completed_mission_ids))
  end

  defp validate_content_by_type(changeset) do
    type = get_field(changeset, :type)
    image_url = get_field(changeset, :image_url)
    content_url = get_field(changeset, :content_url)
    audio_url = get_field(changeset, :audio_url)
    choices = get_field(changeset, :choices)
    
    case type do
      "real_or_fake_image" ->
        changeset
        |> validate_required([:question_text, :correct_answer])
        |> validate_image_url_present()
      
      type when type in ["real_or_fake_video", "real_or_fake_story", "real_or_fake_news"] ->
        changeset
        |> validate_required([:question_text, :correct_answer])
        |> validate_content_url_present()
      
      "spot_the_silly_thing" ->
        changeset
        |> validate_required([:choices])
        |> validate_image_url_present()
        |> validate_audio_fields_present()
        |> validate_choices_format()
      
      "match_sound_to_image" ->
        changeset
        |> validate_required([:audio_url, :choices])
        |> validate_audio_fields_present()
        |> validate_choices_format()
      
      _ -> changeset
    end
  end
  
  defp validate_image_url_present(changeset) do
    if get_field(changeset, :image_url) do
      changeset
    else
      add_error(changeset, :image_url, "is required for this mission type")
    end
  end
  
  defp validate_content_url_present(changeset) do
    if get_field(changeset, :content_url) do
      changeset
    else
      add_error(changeset, :content_url, "is required for this mission type")
    end
  end
  
  defp validate_audio_fields_present(changeset) do
    prompt_audio = get_field(changeset, :prompt_audio_url)
    explanation_audio = get_field(changeset, :explanation_audio_url)
    
    changeset
    |> then(fn cs ->
      if prompt_audio do
        cs
      else
        add_error(cs, :prompt_audio_url, "is required for audio missions")
      end
    end)
    |> then(fn cs ->
      if explanation_audio do
        cs
      else
        add_error(cs, :explanation_audio_url, "is required for audio missions")
      end
    end)
  end
  
  defp validate_choices_format(changeset) do
    choices = get_field(changeset, :choices)
    
    if is_list(choices) && length(choices) >= 2 do
      changeset
    else
      add_error(changeset, :choices, "must have at least 2 choices")
    end
  end
end