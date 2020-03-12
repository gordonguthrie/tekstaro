defmodule Tekstaro.Repo.Migrations.SwitchTextColToTextFromString_II do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      add :text,     :text
      add :username, :string # lost the external reference which was bollox
    end

  end
end
