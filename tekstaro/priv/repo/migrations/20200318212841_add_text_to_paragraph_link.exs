defmodule Tekstaro.Repo.Migrations.AddTextToParagraphLink do
  use Ecto.Migration

  def change do
    alter table(:word) do
      remove :fingerprint
      add    :fingerprint, references(:paragraph, column: :fingerprint, type: :string)
    end
    drop table(:texts)

    create table(:texts) do
      add :url, :string
      add :title, :string
      add :text, :string
      add :fingerprint, :string
      add :username, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:texts, [:fingerprint])

    alter table(:paragraph) do
      add :texts_id, references(:texts)
    end
  end
end
