defmodule Tekstaro.Repo.Migrations.FixSpellingMistake do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :encrypted_password, :string
      remove :encripted_password, :string
    end
  end
end
