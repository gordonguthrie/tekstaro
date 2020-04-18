defmodule Tekstaro.Repo.Migrations.RemoveQuestionMarksFromColumnNames do
  use Ecto.Migration

  def change do

    alter table(:word) do
      remove :is_adjective?
      remove :is_noun?
      remove :is_verbal?
      remove :is_adverb?
      remove :is_correlative?
      remove :is_pronoun?
      remove :is_krokodile?
      remove :is_dictionary_word?
      remove :is_small_word?
      remove :case_marked?
      remove :number_marked?
      remove :is_nickname?
      remove :is_possesive?
      remove :is_participle?
      remove :is_perfect?

      add :is_adjective,       :boolean
      add :is_noun,            :boolean
      add :is_verbal,          :boolean
      add :is_adverb,          :boolean
      add :is_correlative,     :boolean
      add :is_pronoun,         :boolean
      add :is_krokodile,       :boolean
      add :is_dictionary_word, :boolean
      add :is_small_word,      :boolean
      # `marked` shared between nouns, adjectives, adverbs, korrelatives, pronouns
      # and nouns, adjectives.adverbs derived from verbs (eg participles)
      add :case_marked,        :boolean
      # `number` shared between nouns, adjectives, verb parts and pronouns
      add :number_marked,      :boolean
      # only nouns cnn be nicknames
      add :is_nickname,        :boolean
      # only pronouns are possesive
      add :is_possesive,       :boolean
      # set of verb properties
      add :is_participle,      :boolean
      add :is_perfect,         :boolean
    end

  end
end
