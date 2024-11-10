defmodule RealEstateAuctions.Repo.Migrations.AddAdditionalInfoMapToAuctions do
  use Ecto.Migration

  def change do
    alter table("auctions") do
      add :additional_info, :map
    end
  end
end
