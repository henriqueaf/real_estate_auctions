defmodule RealEstateAuctions.Auction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields [:estimated_price, :state, :address, :description, :number, :city, :neighborhood, :start_price, :discount_percent, :sale_mode, :address_link]

  schema "auctions" do
    belongs_to :caixa_file, RealEstateAuctions.CaixaFile

    field :estimated_price, :string
    field :state, Ecto.Enum, values: Application.compile_env(:real_estate_auctions, :available_states)
    field :address, :string
    field :description, :string
    field :number, :string
    field :city, :string
    field :neighborhood, :string
    field :start_price, :string
    field :discount_percent, :string
    field :sale_mode, :string
    field :address_link, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auction, attrs) do
    auction
    |> cast(attrs, [:number, :state, :city, :neighborhood, :address, :start_price, :estimated_price, :discount_percent, :description, :sale_mode, :address_link])
    |> validate_required(@required_fields)
    |> unique_constraint([:number, :state, :sale_mode])
  end
end
