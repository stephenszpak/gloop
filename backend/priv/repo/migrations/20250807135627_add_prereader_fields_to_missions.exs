defmodule RealityAnchor.Repo.Migrations.AddPrereaderFieldsToMissions do
  use Ecto.Migration

  def change do
    alter table(:missions) do
      add :audio_url, :string
      add :prompt_audio_url, :string
      add :explanation_audio_url, :string
      add :emoji_hint, :string
      add :choices, {:array, :map}, default: []
      add :created_by_ai, :boolean, default: false
    end
  end
end
