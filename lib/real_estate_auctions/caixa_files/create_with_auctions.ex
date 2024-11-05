defmodule RealEstateAuctions.CaixaFiles.CreateWithAuctions do
  alias RealEstateAuctions.{Repo, CaixaFile}
  import Ecto.Changeset, only: [cast_assoc: 2]

  def call(caixa_file_params, auction_params_list) do
    %CaixaFile{}
    |> CaixaFile.changeset(Map.merge(caixa_file_params, %{auctions: auction_params_list}))
    |> cast_assoc(:auctions)
    |> Repo.insert()
  end
end
