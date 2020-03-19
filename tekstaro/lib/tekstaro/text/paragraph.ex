defmodule Tekstaro.Text.Paragraph do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:fingerprint, :string, []}
  schema "paragraph" do
    field :text,             :string
    field :sequence,         :integer
    field :no_of_words,      :integer
    field :no_of_characters, :integer
    belongs_to :texts, Tekstaro.Text.Texts
    timestamps()
  end

  @fields [:fingerprint, :text, :texts_id, :sequence, :no_of_words, :no_of_characters]

  @doc false
  def changeset(text, attrs) do
    text
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:fingerprint, name: :paragraph_pkey)
  end
end
