defmodule Tekstaro.Repo.Migrations.DuhMakeTextsFieldOfTypeText do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      remove :text, :string
      add :text, :text
    end
  end
end
