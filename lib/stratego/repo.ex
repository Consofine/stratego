defmodule Stratego.Repo do
  use Ecto.Repo,
    otp_app: :stratego,
    adapter: Ecto.Adapters.Postgres
end
