defmodule RealEstateAuctions.Caixa.Services.FetchAuctionsByState do
  require Logger
  alias RealEstateAuctions.Caixa.{ApiClient, CSVParser}
  alias RealEstateAuctions.CaixaFiles.{Queries}
  alias RealEstateAuctions.{Repo, Auction, FileUtils}

  def call(state) do
    ApiClient.auctions_csv_by_state(state)
    |> handle_api_client_result(state)
  end

  defp handle_api_client_result({:ok, file_content}, state) do
    generate_date = CSVParser.get_generate_date(file_content)

    case find_or_create_caixa_file(state, generate_date, file_content) do
      {:ok, caixa_file} ->
        create_auctions(caixa_file)
      {:error, changeset} ->
        error_messages = RealEstateAuctions.TranslateUtils.translate_errors(changeset)
        FileUtils.log_error_in_file("#{__MODULE__} - find_or_create_caixa_file/3 - state: #{state} - #{error_messages}")
    end
  end
  defp handle_api_client_result({:error, reason}, state) do
    Logger.warning("Error requesting Caixa API for state: #{state}")
    FileUtils.log_error_in_file("#{__MODULE__} - handle_api_client_result/1 - state: #{state} - #{reason}")
  end

  defp find_or_create_caixa_file(state, generate_date, file_content) do
    case Queries.get_by([state: state, generate_date: generate_date]) do
      nil ->
        Logger.info("Creating CaixaFile for state: #{state} and generate_date: #{generate_date}")
        Queries.create(%{generate_date: generate_date, state: state, csv_content: file_content})
      caixa_file ->
        Logger.info("CaixaFile found for state: #{state} and generate_date: #{generate_date}")
        {:ok, caixa_file}
    end
  end

  defp create_auctions(caixa_file) do
    parsed_auctions_list = CSVParser.get_auctions_list(caixa_file.csv_content)
    |> Enum.map(&(Auction.map_to_auction(&1, caixa_file.id)))

    # When there are duplicated/conflict records it will not raise errors due to
    # the "on_conflict: :nothing option"
    Enum.chunk_every(parsed_auctions_list, 1000)
    |> (fn(chuncked) -> Enum.map(chuncked, &(Repo.insert_all(Auction, &1, on_conflict: :nothing))) end).()
  end

  # defp create_tmp_file(state, generate_date, file_content) do
  #   parsed_generate_date = generate_date
  #   |> String.replace("/", "-")

  #   file_name = "caixa_lista_#{state}_#{parsed_generate_date}.csv"

  #   if !File.exists?("#{FileUtils.tmp_folder_path()}/#{file_name}") do
  #     FileUtils.save_file_in_tmp(file_name, file_content)
  #   end
  # end
end
