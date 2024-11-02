defmodule RealEstateAuctions.ApiClients.CaixaApiClient do
  @moduledoc """
  Module responsible to retrieve the CSV file containing the real estate auctions
  list from Caixa API.
  """

  defp api_url, do: Application.get_env(:real_estate_auctions, :caixa_api_url)

  def real_estate_auctions_list_by_state(state) when is_binary(state) do
    state
    |> build_url()
    |> make_request()
    |> handle_http_response()
  end

  defp build_url(state) when is_binary(state) do
    "#{api_url()}/listaweb/Lista_imoveis_#{state}.csv"
  end

  # One thing to note when requesting to Caixa API is that after a successful CSV file
  # request, we are able to make another request only 1 hour after this first request.
  # All other requests in the meantime will fail.
  defp make_request(url) when is_binary(url) do
    HTTPoison.get(url)
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
