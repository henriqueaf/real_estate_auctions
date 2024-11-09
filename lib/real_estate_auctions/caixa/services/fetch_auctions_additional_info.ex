defmodule RealEstateAuctions.Caixa.Services.FetchAuctionsAdditionalInfo do
  require Logger
  alias RealEstateAuctions.{Auction, Repo}
  alias RealEstateAuctions.Caixa.{ApiClient}
  import Ecto.Query, only: [from: 2]

  def call() do
    query_auctions_missing_additional_info()
    |> Repo.all()
    |> Enum.each(fn auction ->
      fetch_auction_additional_info(auction)
      :timer.sleep(1000)
    end)
  end

  defp query_auctions_missing_additional_info() do
    from(
      a in Auction,
      where: is_nil(a.real_estate_type)
        or is_nil(a.real_estate_registration)
        or is_nil(a.real_estate_inscription)
    )
  end

  defp fetch_auction_additional_info(%Auction{} = auction) do
    Logger.warning("Fething => #{auction.address_link} sale_mode => #{auction.sale_mode}")

    case ApiClient.auction_details_page(auction.address_link) do
      {:ok, html} ->
        save_additional_info(html, auction)
      {:error, reason} ->
        Logger.error("Error requesting additional data for auction(#{auction.id}): #{IO.inspect(reason)}")
    end
  end

  defp save_additional_info(html, auction) do
    {:ok, document} = Floki.parse_document(html)

    spans = Floki.find(document, "#dadosImovel .content-wrapper.clearfix .content div:first-of-type span")

    case Enum.empty?(spans) do
      true ->
        Logger.error("Page content not expected. Probably the auction is finished for this sale_mode.")
      false -> spans
        |> Enum.map(fn span ->
          case span do
            {"span", [], ["Tipo de imóvel: ", {"strong", [], [real_estate_type]}]} -> %{real_estate_type: real_estate_type}
            {"span", [], ["Matrícula(s): ", {"strong", [], [real_estate_registration]}]} -> %{real_estate_registration: real_estate_registration}
            {"span", [], ["Inscrição imobiliária: ", {"strong", [], [real_estate_inscription]}]} -> %{real_estate_inscription: real_estate_inscription}
            {"span", [], ["Averbação dos leilões negativos: ", {"strong", [], [registration_of_negative_auctions]}]} -> %{registration_of_negative_auctions: String.trim(registration_of_negative_auctions)}
            _ -> nil
          end
        end)
        |> Enum.filter(&(!is_nil(&1)))
        |> Enum.reduce(&Map.merge/2)
        |> Map.merge(%{
          registration_file_path: registration_file_path(auction),
          notice_file_path: notice_file_path(auction, document),
          financial_conditions_info: Floki.find(document, "#dadosImovel .related-box p:last-child") |> Floki.text
        })
        |> update_auction(auction)
    end
  end

  defp registration_file_path(%Auction{} = auction) do
    "/editais/matricula/#{auction.state}/#{String.pad_leading(auction.number, 13, "0")}.pdf"
  end

  defp notice_file_path(%Auction{sale_mode: sale_mode}, floki_document) do
    if String.downcase(sale_mode) |> String.contains?("venda") do
      nil
    else
      onclick_content = List.first(
        Floki.find(floki_document, "#dadosImovel .content-wrapper .form-set.no-bullets li a")
        |> Floki.attribute("onclick")
      )

      case is_nil(onclick_content) do
        true ->
          Logger.warning("Onclick link for notice_file_path not found. Probably this auction has changed the sale_mode.")
          nil
        false -> String.slice(onclick_content, 21..-3//1)
      end
    end
  end

  defp update_auction(additional_info_attrs, %Auction{} = auction) do
    auction
    |> Auction.changeset(additional_info_attrs)
    |> Repo.update()
  end
end