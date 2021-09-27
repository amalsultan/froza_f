defmodule Froza.Repo do
  use Ecto.Repo,
    otp_app: :froza,
    adapter: Ecto.Adapters.Postgres
end
