defmodule Tekstaro.Text.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "word" do
    field :fingerprint,         :string
    field :word,                :string
    field :root,                :string
    field :starting_position,   :integer
    field :length,              :integer
    field :is_adjective?,       :boolean
    field :is_noun?,            :boolean
    field :is_verbal?,          :boolean
    field :is_adverb?,          :boolean
    field :is_correlative?,     :boolean
    field :is_pronoun?,         :boolean
    field :is_krokodile?,       :boolean
    field :is_dictionary_word?, :boolean
    field :is_small_word?,      :boolean
    # `marked` shared between nouns, adjectives, adverbs, korrelatives, pronouns
    # and nouns, adjectives.adverbs derived from verbs (eg participles)
    field :case_marked?, :boolean
    # `number` shared between nouns, adjectives, verb parts and pronouns
    field :number_marked?, :boolean
    # only nouns cnn be nicknames
    field :is_nickname?, :boolean
    # only pronouns are possesive
    field :is_possesive?, :boolean
    # set of verb properties
    field :form,           :string
    field :voice,          :string
    field :aspect,         :string
    field :is_participle?, :boolean
    field :is_perfect?,    :boolean
    belongs_to :paragraph, Tekstaro.Text.Paragraph
    timestamps()
    has_many :affix, Tekstaro.Text.Affix
  end

  @fields [
    :fingerprint,
    :word,
    :root,
    :starting_position,
    :length,
    :is_adjective?,
    :is_noun?,
    :is_verbal?,
    :is_adverb?,
    :is_correlative?,
    :is_pronoun?,
    :is_krokodile?,
    :is_dictionary_word?,
    :is_small_word?,
    :case_marked?,
    :number_marked?,
    :is_nickname?,
    :is_possesive?,
    :form,
    :voice,
    :aspect,
    :is_participle?,
    :is_perfect?
  ]

  @required [
    :fingerprint,
    :word,
    :starting_position,
    :length,
    :is_adjective?,
    :is_noun?,
    :is_verbal?,
    :is_adverb?,
    :is_correlative?,
    :is_pronoun?,
    :is_krokodile?,
    :is_dictionary_word?,
    :is_small_word?,
    :case_marked?,
    :number_marked?,
    :is_nickname?,
    :is_possesive?,
    :is_participle?,
    :is_perfect?
  ]

  @doc false
  def changeset(text, attrs) do
    text
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
