defmodule Tekstaro.Repo.Migrations.AddTimestampsToAffix do
  use Ecto.Migration

  def change do
    alter table(:affix) do
      timestamps()
    end
  end
end
