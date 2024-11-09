defmodule RealEstateAuctions.Caixa.Services.FetchAuctionAdditionalInfo do
  alias RealEstateAuctions.{Auction, Repo}
  alias RealEstateAuctions.Caixa.{ApiClient}

  def call(%Auction{} = auction) do
    case ApiClient.auction_details_page(auction.address_link) do
      {:ok, html} ->
        additional_info_attributes(html, auction)
        |> save_additional_info(auction)
      {:error, _reason} ->
        # Starts this same module call function in a Task
        Task.start(fn ->
          :timer.sleep(10000)
          __MODULE__.call(auction)
        end)
    end
  end

  defp additional_info_attributes(html, auction) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find(document, "#dadosImovel .content-wrapper.clearfix .content div:first-of-type span")
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
  end

  defp registration_file_path(%Auction{} = auction) do
    "/editais/matricula/#{auction.state}/#{String.pad_leading(auction.number, 13, "0")}.pdf"
  end

  defp notice_file_path(%Auction{sale_mode: sale_mode}, floki_document) do
    if String.downcase(sale_mode) |> String.contains?("venda") do
      nil
    else
      List.first(
        Floki.find(floki_document, "#dadosImovel .content-wrapper .form-set.no-bullets li a")
        |> Floki.attribute("onclick")
      )
      |> String.slice(21..-3//1)
    end
  end

  defp save_additional_info(additional_info_attrs, %Auction{} = auction) do
    auction
    |> Auction.changeset(additional_info_attrs)
    |> Repo.update()
  end
end
