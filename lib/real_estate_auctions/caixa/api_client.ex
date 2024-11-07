defmodule RealEstateAuctions.Caixa.ApiClient do
  @moduledoc """
  Module responsible to retrieve the CSV file containing the real estate auctions
  list from Caixa API.
  """

  defp api_base_url, do: Application.get_env(:real_estate_auctions, :caixa_api_url)

  @doc """
  Returns the CSV file content related to the state requested.
  It accepts an Atom as parameter referring the desired state like => :CE.

  ## Examples

    iex> RealEstateAuctions.Caixa.ApiClient.auctions_csv_by_state(:CE)
    {:ok,
    <<10, 32, 76, 105, 115, 116, 97, 32, 100, 101, 32, 73, 109, 243, 118, 101, 105,
      115, 32, 100, 97, 32, 67, 97, 105, 120, 97, 59, 59, 68, 97, 116, 97, 32, 100,
      101, 32, 103, 101, 114, 97, 231, 227, 111, 58, 59, 48, 53, ...>>}

  """
  def auctions_csv_by_state(state) when is_atom(state) do
    state
    |> build_url()
    |> make_request()
    |> handle_http_response()
  end

  def auction_details_page(auction_address_link) when is_binary(auction_address_link) do
    auction_address_link
    |> make_request()
    |> handle_http_response()
  end

  defp build_url(state) when is_atom(state) do
    "#{api_base_url()}/listaweb/Lista_imoveis_#{state}.csv"
  end

  defp make_request(url) when is_binary(url) do
    headers = %{"Origin" => api_base_url(), "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64)"}
    HTTPoison.get(url, headers)
  end

  defp handle_http_response({response_status, response}) do
    case response_status do
      :ok -> handle_ok_response(response)
      :error -> handle_error_response(response)
    end
  end

  defp handle_ok_response(%HTTPoison.Response{status_code: status_code, body: body}) do
    case status_code do
      200 -> {:ok, body}
      _ -> {:error, body}
    end
  end

  defp handle_error_response(%HTTPoison.Error{} = error) do
    {:error, Exception.message(error)}
  end
end
