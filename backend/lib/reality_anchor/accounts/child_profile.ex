defmodule RealityAnchor.Accounts.ChildProfile do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias RealityAnchor.Accounts.User
  alias RealityAnchor.Missions.Submission

  schema "child_profiles" do
    field :name, :string
    field :avatar_emoji, :string, default: "🧒"
    field :birth_year, :integer
    
    belongs_to :user, User
    has_many :submissions, Submission, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(child_profile, attrs) do
    child_profile
    |> cast(attrs, [:name, :avatar_emoji, :birth_year, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: 1, max: 50)
    |> validate_avatar_emoji()
    |> validate_birth_year()
    |> unique_constraint([:user_id, :name], 
         message: "A child with this name already exists for this parent")
  end

  @doc """
  Get child's age based on birth year
  """
  def age(%__MODULE__{birth_year: nil}), do: nil
  def age(%__MODULE__{birth_year: birth_year}) do
    current_year = Date.utc_today().year
    current_year - birth_year
  end

  @valid_avatars ~w(🧒 👦 👧 🦄 🚀 🌟 🎯 🏆 🎨 🎭 🎪 🎈 🎉 🎊 ⭐ 🌈 🦸‍♂️ 🦸‍♀️ 🧙‍♂️ 🧙‍♀️)

  defp validate_avatar_emoji(changeset) do
    avatar = get_field(changeset, :avatar_emoji)
    
    if avatar && avatar in @valid_avatars do
      changeset
    else
      add_error(changeset, :avatar_emoji, "must be a valid child-friendly emoji")
    end
  end

  defp validate_birth_year(changeset) do
    current_year = Date.utc_today().year
    
    changeset
    |> validate_number(:birth_year, 
         greater_than: current_year - 12,  # Max 12 years old
         less_than: current_year - 3)      # Min 3 years old
  end

  @doc """
  Returns available avatar emojis for selection
  """
  def available_avatars, do: @valid_avatars
end