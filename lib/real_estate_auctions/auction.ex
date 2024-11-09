defmodule RealEstateAuctions.Auction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields [:estimated_price, :state, :address, :description, :number, :city, :neighborhood, :start_price, :discount_percent, :sale_mode, :address_link]
  @not_required_fields [:real_estate_type, :real_estate_registration, :real_estate_inscription, :registration_of_negative_auctions, :financial_conditions_info, :registration_file_path, :notice_file_path]

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
    # Additional info
    field :real_estate_type, :string
    field :real_estate_registration, :string # Matrícula
    field :real_estate_inscription, :string # Inscrição imobiliária (IPTU)
    field :registration_of_negative_auctions, :string
    field :financial_conditions_info, :string
    field :registration_file_path, :string
    field :notice_file_path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auction, attrs) do
    auction
    |> cast(attrs, @required_fields ++ @not_required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:number, :state, :sale_mode])
  end

  def map_to_auction(%{} = map, caixa_file_id) do
    utc_now = DateTime.truncate(DateTime.utc_now, :second)

    struct(__MODULE__, map)
    |> Map.merge(%{
      state: String.to_atom(map.state),
      inserted_at: utc_now,
      updated_at: utc_now,
      caixa_file_id: caixa_file_id
    })
    |> Map.drop([:__struct__, :__meta__, :caixa_file, :id])
  end
end
