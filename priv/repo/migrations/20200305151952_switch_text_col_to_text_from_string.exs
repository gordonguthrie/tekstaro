defmodule Tekstaro.Repo.Migrations.SwitchTextColToTextFromString do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      remove :text, :string
      remove :username, :string
    end
  end
end
