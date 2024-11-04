defmodule RealEstateAuctions.Auctions.Create do
  alias RealEstateAuctions.{Auction, Repo}

  def call(params) do
    %Auction{}
    |> Auction.changeset(params)
    |> Repo.insert()
    |> handle_insert()
  end

  defp handle_insert({:ok, %Auction{}} = result), do: result
  defp handle_insert({:error, result}), do: {:error, %{result: result, errors: result.errors}}
end
