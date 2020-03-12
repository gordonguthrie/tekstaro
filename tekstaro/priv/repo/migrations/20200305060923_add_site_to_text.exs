defmodule Tekstaro.Repo.Migrations.AddSiteToText do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      add  :site, :string
    end
  end
end
