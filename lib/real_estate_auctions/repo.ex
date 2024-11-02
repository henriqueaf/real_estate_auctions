defmodule RealEstateAuctions.Repo do
  use Ecto.Repo,
    otp_app: :real_estate_auctions,
    adapter: Ecto.Adapters.Postgres
end
