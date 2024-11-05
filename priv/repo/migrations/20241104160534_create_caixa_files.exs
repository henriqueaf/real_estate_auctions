defmodule RealEstateAuctions.Repo.Migrations.CreateCaixaFiles do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create table(:caixa_files) do
      add :state, :string, null: false
      add :generate_date, :string, null: false
      add :csv_content, :binary, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:caixa_files, [:state, :generate_date], concurrently: true)
  end
end
