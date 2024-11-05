defmodule RealEstateAuctions.CaixaFiles.Create do
  alias RealEstateAuctions.{CaixaFile, Repo}

  def call(params) do
    %CaixaFile{}
    |> CaixaFile.changeset(params)
    |> Repo.insert()
  end
end
