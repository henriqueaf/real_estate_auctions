defmodule RealEstateAuctions.AuctionsServices.CaixaService do
  require Logger
  alias RealEstateAuctions.ApiClients.{CaixaApiClient}
  alias RealEstateAuctions.{FileUtils, DateUtils}
  alias RealEstateAuctions.AuctionsServices.CaixaService.{CSVParser}

  defp available_states(), do: ["CE"]

  def fetch_real_estate_auctions() do
    for state <- available_states() do
      CaixaApiClient.real_estate_auctions_list_by_state(state)
      |> handle_api_client_result(state)
    end
  end

  defp handle_api_client_result({:ok, file_content}, state) do
    generate_date = CSVParser.get_generate_date(file_content)
    |> String.replace("/", "-")

    file_name = "caixa_lista_#{state}_#{generate_date}.csv"

    # TODO: Change saving data in file to save data in Database. %{state: CE, generate_date: "01/11/2024, file_content: <binary_content>"}
    if !File.exists?("#{FileUtils.tmp_folder_path()}/#{file_name}") do
      FileUtils.save_file_in_tmp(file_name, file_content)
    end
  end
  defp handle_api_client_result({:error, reason}, state) do
    Logger.warning("Error requesting Caixa API for state: #{state}")
    FileUtils.log_error_in_file("#{__MODULE__} - handle_api_client_result/1 - state: #{state} - #{reason}")
  end
end
