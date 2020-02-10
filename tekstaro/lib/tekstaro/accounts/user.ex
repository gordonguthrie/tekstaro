defmodule Tekstaro.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :encripted_password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :encripted_password])
    |> validate_required([:username, :encripted_password])
    |> unique_constraint(:username)
    |> update_change(:encrypted_password, &Bcrypt.hash_pwd_salt/1)
  end
end
