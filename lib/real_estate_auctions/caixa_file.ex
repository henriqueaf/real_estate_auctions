defmodule RealEstateAuctions.CaixaFile do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:state, :generate_date, :csv_content]

  schema "caixa_files" do
    has_many :auctions, RealEstateAuctions.Auction

    field :state, Ecto.Enum, values: Application.compile_env(:real_estate_auctions, :available_states)
    field :generate_date, :string
    field :csv_content, :binary

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(caixa_file, attrs) do
    caixa_file
    |> cast(attrs, [:state, :generate_date, :csv_content])
    |> validate_required(@required_fields)
    |> unique_constraint([:state, :generate_date])
  end
end
