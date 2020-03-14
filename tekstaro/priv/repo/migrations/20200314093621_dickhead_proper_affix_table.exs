defmodule Tekstaro.Repo.Migrations.DickheadProperAffixTable do
  use Ecto.Migration

  def change do
    drop table(:affix)
    create table(:affix) do
      add :word_id, references(:word)
      add :affix, :string
      add :type, :string
      add :position, :integer
      timestamps()
    end
  end
end
