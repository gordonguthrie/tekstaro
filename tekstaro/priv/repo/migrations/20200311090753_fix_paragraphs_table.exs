defmodule Tekstaro.Repo.Migrations.FixParagraphsTable do
  use Ecto.Migration

  def change do
    drop table(:paragraph)
    create table(:paragraph, primary_key: false) do
      add :fingerprint,      :string, primary_key: true
      add :text,             :text
      add :sequence,         :int
      add :no_of_words,      :int
      add :no_of_characters, :int

      timestamps()
    end
    create unique_index(:paragraph, [:fingerprint])

  end
end
