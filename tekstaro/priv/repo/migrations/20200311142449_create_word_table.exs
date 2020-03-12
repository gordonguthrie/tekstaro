defmodule Tekstaro.Repo.Migrations.CreateWordTable do
  use Ecto.Migration

  def change do

    create table(:word) do
      add :fingerprint,         :string
      add :word,                :string
      add :root,                :string
      add :starting_position,   :integer
      add :length,              :integer
      add :is_adjective?,       :boolean
      add :is_noun?,            :boolean
      add :is_verbal?,          :boolean
      add :is_adverb?,          :boolean
      add :is_corelative?,      :boolean
      add :is_pronoun?,         :boolean
      add :is_krokodile?,       :boolean
      add :is_dictionary_word?, :boolean
      add :is_small_word?,      :boolean
      # `marked` shared between nouns, adjectives, adverbs, korrelatives, pronouns
      # and nouns, adjectives.adverbs derived from verbs (eg participles)
      add :case_marked?,        :boolean
      # `number` shared between nouns, adjectives, verb parts and pronouns
      add :number_marked?,      :boolean
      # only nouns cnn be nicknames
      add :is_nickname?,        :boolean
      # only pronouns are possesive
      add :is_possesive?,       :boolean
      # set of verb properties
      add :form,                :string
      add :voice,               :string
      add :aspect,              :string
      add :is_participle?,      :boolean
      add :is_perfect?,         :boolean
    end
    create index(:word, [:word, :root, :fingerprint])
  end

  #create table(:affix, primary_key: false) do
  #  add :word_id,  references(:word)
  #  add :affix,    :string
  #  add :type,     :string
  #  add :position, :integer
  #end

end
