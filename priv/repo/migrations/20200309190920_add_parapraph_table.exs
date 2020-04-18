defmodule Tekstaro.Repo.Migrations.AddParapraphTable do
  use Ecto.Migration

  def change do
    create table(:paragraph) do
      add :text, :text
      add :fingerprint, :string
      add :sequence, :int
      add :no_of_words, :int
      add :no_of_characters, :int

      timestamps()
    end
  end
end
