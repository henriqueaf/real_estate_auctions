defmodule RealEstateAuctions.CaixaFiles.GetBy do
  alias RealEstateAuctions.{CaixaFile, Repo}

  def call(params) do
    CaixaFile
    |> Repo.get_by(params)
  end
end
