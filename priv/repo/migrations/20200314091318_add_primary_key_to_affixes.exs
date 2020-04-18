defmodule Tekstaro.Repo.Migrations.AddPrimaryKeyToAffixes do
  use Ecto.Migration

  def change do
    drop table(:affix)
    create table(:affix, primary_key: false) do
      add :word_id, references(:word)
      add :affix, :string
      add :type, :string
      add :position, :integer
    end
  end
end
