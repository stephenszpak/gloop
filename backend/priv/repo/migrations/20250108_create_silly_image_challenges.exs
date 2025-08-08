defmodule RealityAnchor.Repo.Migrations.CreateSillyImageChallenges do
  use Ecto.Migration

  def change do
    create table(:silly_image_challenges) do
      add :title, :string, null: false
      add :image_url, :string, null: false
      add :regions, {:array, :map}, null: false, default: []
      add :difficulty, :string, null: false, default: "easy"
      add :created_by_ai, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:silly_image_challenges, [:difficulty])
    create index(:silly_image_challenges, [:created_by_ai])
  end
end