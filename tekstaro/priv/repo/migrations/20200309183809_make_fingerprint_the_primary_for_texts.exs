defmodule Tekstaro.Repo.Migrations.MakeFingerprintThePrimaryForTexts do
  use Ecto.Migration

  def change do
    drop table(:texts)
    create table(:texts, primary_key: false) do
      add :url,            :string
      add :title,          :string
      add :text,           :string
      add :fingerprint,    :string, primary_key: true
      add :username,       :string

      timestamps()
    end
    create unique_index(:texts, [:username, :fingerprint])
  end
end
