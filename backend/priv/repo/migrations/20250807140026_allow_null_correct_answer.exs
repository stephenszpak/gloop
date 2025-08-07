defmodule RealityAnchor.Repo.Migrations.AllowNullCorrectAnswer do
  use Ecto.Migration

  def change do
    alter table(:missions) do
      modify :correct_answer, :boolean, null: true
      modify :question_text, :string, null: true
    end
  end
end
