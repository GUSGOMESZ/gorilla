defmodule Gorilla.Repo do
  use Ecto.Repo,
    otp_app: :gorilla,
    adapter: Ecto.Adapters.Postgres
end
