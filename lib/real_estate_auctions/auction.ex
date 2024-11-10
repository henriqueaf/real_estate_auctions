defmodule RealEstateAuctions.Auction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @required_fields [:estimated_price, :state, :address, :description, :number, :city, :start_price, :discount_percent, :sale_mode, :address_link]
  @not_required_fields [:additional_info, :neighborhood]

  defp additional_info_keys do
    ~w{real_estate_type real_estate_registration real_estate_inscription
    registration_of_negative_auctions registration_file_path notice_file_path
    real_estate_picture_srcs financial_conditions_info}
  end

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
    field :additional_info, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(auction, attrs) do
    auction
    |> cast(attrs, @required_fields ++ @not_required_fields)
    |> validate_required(@required_fields)
    |> validate_change(:additional_info, fn (:additional_info, new_additional_info) ->
      IO.inspect(Enum.map(additional_info_keys(), &(Map.has_key?(new_additional_info, &1))))
      cond do
        Enum.sort(additional_info_keys()) == Enum.sort(Map.keys(new_additional_info)) -> []

        true -> [additional_info: {"wrong keys", exact_keys: additional_info_keys()}]
      end
    end)
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

  def set_additional_info_map_values(value) do
    Map.new(additional_info_keys(), &({&1, value}))
  end
end
