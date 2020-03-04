defmodule Tekstaro.Repo.Migrations.CreateTextTable do
  use Ecto.Migration

  def change do
    create table(:texts) do
      add :url,            :string
      add :title,          :string
      add :text,           :string
      add :fingerprint,    :string
      add :username,       references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:texts, [:username, :fingerprint])

  end
end
