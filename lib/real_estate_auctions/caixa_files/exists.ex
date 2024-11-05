defmodule RealEstateAuctions.CaixaFiles.Exists do
  alias RealEstateAuctions.{CaixaFile, Repo}
  import Ecto.Query, only: [from: 2]

  def call(params) do
    from(CaixaFile, where: ^params)
    |> Repo.exists?()
  end
end
