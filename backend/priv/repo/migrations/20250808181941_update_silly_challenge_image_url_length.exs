defmodule RealityAnchor.Repo.Migrations.UpdateSillyChallengeImageUrlLength do
  use Ecto.Migration

  def change do
    alter table(:silly_image_challenges) do
      modify :image_url, :text
    end
  end
end