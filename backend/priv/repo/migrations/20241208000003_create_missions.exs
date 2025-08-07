defmodule RealityAnchor.Repo.Migrations.CreateMissions do
  use Ecto.Migration

  def change do
    create table(:missions) do
      add :title, :string, null: false
      add :type, :string, null: false, default: "real_or_fake_image"
      add :image_url, :string
      add :content_url, :string  # For video/audio missions
      add :question_text, :text, null: false
      add :correct_answer, :boolean, null: false
      add :explanation, :text, null: false
      add :difficulty_level, :integer, null: false, default: 1
      add :is_active, :boolean, null: false, default: true
      add :tags, {:array, :string}, default: []
      
      timestamps()
    end

    create index(:missions, [:type])
    create index(:missions, [:difficulty_level])
    create index(:missions, [:is_active])
  end
end