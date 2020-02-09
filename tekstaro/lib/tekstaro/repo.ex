defmodule Tekstaro.Repo do
  use Ecto.Repo,
    otp_app: :tekstaro,
    adapter: Ecto.Adapters.Postgres
end
