defmodule Counselling.Repo do
  use Ecto.Repo,
    otp_app: :counselling,
    adapter: Ecto.Adapters.Postgres
end
