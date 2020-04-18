defmodule Tekstaro.Repo.Migrations.SwitchTextColToTextFromString_II do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      add :text, :text
      # lost the external reference which was bollox
      add :username, :string
    end
  end
end
