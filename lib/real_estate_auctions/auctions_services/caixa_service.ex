defmodule RealEstateAuctions.AuctionsServices.CaixaService do
  require Logger
  alias RealEstateAuctions.ApiClients.{CaixaApiClient}
  alias RealEstateAuctions.{FileUtils, DateUtils}

  defp available_states(), do: ["CE"]

  def fetch_real_estate_auctions() do
    for state <- available_states() do
      CaixaApiClient.real_estate_auctions_list_by_state(state)
      |> handle_api_client_result(state)
    end
  end

  defp handle_api_client_result({:ok, file_content}, state) do
    file_name = "caixa_lista_#{state}_#{DateUtils.current_date_time_string()}.csv"
    FileUtils.save_file_in_tmp(file_name, file_content)
  end
  defp handle_api_client_result({:error, reason}, state) do
    Logger.warning("Error requesting Caixa API for state: #{state}")
    FileUtils.log_error_in_file("#{__MODULE__} - handle_api_client_result/1 - state: #{state} - #{reason}")
  end
end
