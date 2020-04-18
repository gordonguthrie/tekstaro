defmodule Tekstaro.Repo.Migrations.StatsTable do
  use Ecto.Migration

  def change do
    create table(:stats) do
      add :name,  :string
      add :count, :string
      timestamps()
    end

  end
end
