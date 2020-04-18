defmodule Tekstaro.Repo.Migrations.RemoveIsDictionaryField do
  use Ecto.Migration

  def change do
    alter table(:word) do
      remove :is_dictionary_word
    end
  end
end
