defmodule Social.Repo do
  use Ecto.Repo,
    otp_app: :social,
    adapter: Ecto.Adapters.Postgres
end
