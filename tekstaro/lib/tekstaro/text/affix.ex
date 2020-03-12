defmodule Tekstaro.Text.Affix do
  use Ecto.Schema
  import Ecto.Changeset

  schema "affix" do

    field :affix,    :string
    field :type,     :string
    field :position, :integer
    belongs_to :word, Tekstaro.Text.Word
    timestamps()
    
  end

  @fields [
      :affix,
      :type,
      :postion
    ]

  @doc false
  def changeset(text, attrs) do
    text
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
