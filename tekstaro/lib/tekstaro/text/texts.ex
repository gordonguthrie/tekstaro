defmodule Tekstaro.Text.Texts do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:fingerprint, :string, []}
  schema "texts" do
    field :url,      :string
    field :site,     :string
    field :title,    :string
    field :text,     :string
    field :username, :string

    timestamps()
  end

  @fields [:url, :site, :title, :text, :fingerprint, :username]

  @doc false
  def changeset(text, attrs) do
    text
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:fingerprint)
  end
end
