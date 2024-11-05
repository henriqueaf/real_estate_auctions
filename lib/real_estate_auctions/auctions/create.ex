defmodule RealEstateAuctions.Auctions.Create do
  alias RealEstateAuctions.{Auction, Repo}

  def call(params) do
    %Auction{}
    |> Auction.changeset(params)
    |> Repo.insert()
  end
end
