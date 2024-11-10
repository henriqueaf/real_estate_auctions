defmodule RealEstateAuctions.Repo.Migrations.RemoveAdditionalFieldsFromAuctions do
  use Ecto.Migration

  def change do
    alter table("auctions") do
      remove :real_estate_type
      remove :real_estate_registration
      remove :real_estate_inscription
      remove :registration_of_negative_auctions
      remove :financial_conditions_info
      remove :registration_file_path
      remove :notice_file_path
    end
  end
end
