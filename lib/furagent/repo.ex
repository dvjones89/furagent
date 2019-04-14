defmodule Furagent.Repo do
  use Ecto.Repo,
    otp_app: :furagent,
    adapter: Ecto.Adapters.Postgres
end
