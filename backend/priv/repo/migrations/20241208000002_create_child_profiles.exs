defmodule RealityAnchor.Repo.Migrations.CreateChildProfiles do
  use Ecto.Migration

  def change do
    create table(:child_profiles) do
      add :name, :string, null: false
      add :avatar_emoji, :string, null: false, default: "🧒"
      add :birth_year, :integer
      add :user_id, references(:users, on_delete: :delete_all), null: false
      
      timestamps()
    end

    create index(:child_profiles, [:user_id])
    create unique_index(:child_profiles, [:user_id, :name])
  end
end