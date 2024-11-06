defmodule RealEstateAuctions.CaixaFiles.Queries do
  alias RealEstateAuctions.{CaixaFile, Repo}
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset, only: [cast_assoc: 2]

  def exists?(params) do
    from(CaixaFile, where: ^params)
    |> Repo.exists?()
  end

  def create_with_auctions(caixa_file_params, auction_params_list) do
    %CaixaFile{}
    |> CaixaFile.changeset(Map.merge(caixa_file_params, %{auctions: auction_params_list}))
    |> cast_assoc(:auctions)
    |> Repo.insert(on_conflict: :nothing)
  end

  def create(params) do
    %CaixaFile{}
    |> CaixaFile.changeset(params)
    |> Repo.insert()
  end

  def get_by(params) do
    CaixaFile
    |> Repo.get_by(params)
  end

  def delete_auctions!(%CaixaFile{} = caixa_file) do
    Repo.delete_all(Ecto.assoc(caixa_file, :auctions))
  end
end
