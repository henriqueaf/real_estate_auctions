defmodule RealEstateAuctions.Repo.Migrations.AuctionsAddColumns do
  use Ecto.Migration

  def change do
    alter table("auctions") do
      add :real_estate_type, :string
      add :real_estate_registration, :string
      add :real_estate_inscription, :string
      add :registration_of_negative_auctions, :string
      add :financial_conditions_info, :text
      add :registration_file_path, :string
      add :notice_file_path, :string
    end
  end
end
