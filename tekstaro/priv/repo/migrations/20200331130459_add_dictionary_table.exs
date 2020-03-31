defmodule Tekstaro.Repo.Migrations.AddDictionaryTable do
  use Ecto.Migration

  def change do
    
      create table(:dictionary) do
        add :root,            :string
        add :is_verb,         :boolean
        add :is_transitive,   :boolean
        add :is_intransitive, :boolean
        add :etymology,       :string
        timestamps()
      end
  end
end
