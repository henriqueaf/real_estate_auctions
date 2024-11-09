defmodule RealEstateAuctions.Auctions.Queries do
  alias RealEstateAuctions.{Auction, Repo}

  def create(params) do
    %Auction{}
    |> Auction.changeset(params)
    |> Repo.insert()
  end
end
