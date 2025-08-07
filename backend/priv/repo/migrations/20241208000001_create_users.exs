defmodule RealityAnchor.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :name, :string, null: false
      add :confirmed_at, :naive_datetime
      
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end