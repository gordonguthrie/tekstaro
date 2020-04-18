defmodule Tekstaro.Repo.Migrations.SpellingCorrectionForCorrelative do
  use Ecto.Migration

  def change do
    alter table(:word) do
      remove :is_corelative?,  :boolean
      add    :is_correlative?, :boolean
    end

  end
end
