defmodule RealEstateAuctions.Repo.Migrations.CreateAuctions do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create table(:auctions, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :number, :string, null: false
      add :state, :string, null: false
      add :city, :string, null: false
      add :neighborhood, :string, null: false
      add :address, :string, null: false
      add :start_price, :string, null: false
      add :estimated_price, :string, null: false
      add :discount_percent, :string, null: false
      add :description, :string
      add :sale_mode, :string, null: false
      add :address_link, :string, null: false

      add :caixa_file_id, references(:caixa_files)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:auctions, [:number, :state, :sale_mode], concurrently: true)
  end
end
