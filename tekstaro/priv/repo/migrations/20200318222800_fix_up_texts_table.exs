defmodule Tekstaro.Repo.Migrations.FixUpTextsTable do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      remove :text,     :string
      remove :username, :string
    end
    alter table(:texts) do
      add    :text,     :text
      add    :username, :string
    end
  end
end
