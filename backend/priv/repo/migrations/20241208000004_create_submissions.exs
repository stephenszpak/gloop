defmodule RealityAnchor.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :selected_answer, :boolean, null: false
      add :is_correct, :boolean, null: false
      add :time_spent_ms, :integer, null: false, default: 0
      add :child_profile_id, references(:child_profiles, on_delete: :delete_all), null: false
      add :mission_id, references(:missions, on_delete: :delete_all), null: false
      
      timestamps()
    end

    create index(:submissions, [:child_profile_id])
    create index(:submissions, [:mission_id])
    create index(:submissions, [:is_correct])
    create index(:submissions, [:inserted_at])
    
    # Prevent duplicate submissions for same child + mission
    create unique_index(:submissions, [:child_profile_id, :mission_id])
  end
end