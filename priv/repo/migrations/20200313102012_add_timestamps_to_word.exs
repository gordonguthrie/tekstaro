defmodule Tekstaro.Repo.Migrations.AddTimestampsToWord do
  use Ecto.Migration

  def change do
    alter table(:word) do
      timestamps()
    end
  end
end
