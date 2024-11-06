defmodule RealEstateAuctions.Caixa.Service do
  require Logger
  alias RealEstateAuctions.Caixa.{ApiClient, CSVParser}
  alias RealEstateAuctions.CaixaFiles.{Queries}
  alias RealEstateAuctions.{Repo, Auction, FileUtils}

  def fetch_auctions() do
    for state <- Application.get_env(:real_estate_auctions, :available_states) do
      ApiClient.auctions_csv_by_state(state)
      |> handle_api_client_result(state)
    end
  end

  defp handle_api_client_result({:ok, file_content}, state) do
    generate_date = CSVParser.get_generate_date(file_content)

    create_tmp_file(state, generate_date, file_content)

    # case create_caixa_file_and_auctions(state, generate_date, file_content) do
    #   {:ok, struct} -> Logger.info("CaixaFile created for state: #{struct.state} and generate_date: #{struct.generate_date}")
    #   {:error, changeset} ->
    #     error_messages = RealEstateAuctions.TranslateUtils.translate_errors(changeset)
    #     FileUtils.log_error_in_file("#{__MODULE__} - create_caixa_file/3 - state: #{state} - #{error_messages}")
    # end

    case find_or_create_caixa_file(state, generate_date, file_content) do
      {:ok, caixa_file} ->
        Logger.info("CaixaFile created for state: #{caixa_file.state} and generate_date: #{caixa_file.generate_date}")
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

  # defp create_caixa_file_and_auctions(state, generate_date, file_content) do
  #   auctions_list = CSVParser.get_auctions_list(file_content)

  #   Queries.create_with_auctions(
  #     %{generate_date: generate_date, state: state, csv_content: file_content},
  #     auctions_list
  #   )
  # end

  defp find_or_create_caixa_file(state, generate_date, file_content) do
    case Queries.get_by([state: state, generate_date: generate_date]) do
      nil -> Queries.create(%{generate_date: generate_date, state: state, csv_content: file_content})
      caixa_file -> {:ok, caixa_file}
    end
  end

  defp create_auctions(caixa_file) do
    utc_now = DateTime.truncate(DateTime.utc_now, :second)

    auctions_list = CSVParser.get_auctions_list(caixa_file.csv_content)
    |> Enum.map(
      &(struct(Auction, &1))
      |> Map.merge(%{
          state: caixa_file.state,
          inserted_at: utc_now,
          updated_at: utc_now,
          caixa_file_id: caixa_file.id
        })
      |> Map.drop([:__struct__, :__meta__, :caixa_file, :id])
    )

    Repo.insert_all(Auction, auctions_list, on_conflict: :nothing)
  end

  defp create_tmp_file(state, generate_date, file_content) do
    parsed_generate_date = generate_date
    |> String.replace("/", "-")

    file_name = "caixa_lista_#{state}_#{parsed_generate_date}.csv"

    if !File.exists?("#{FileUtils.tmp_folder_path()}/#{file_name}") do
      FileUtils.save_file_in_tmp(file_name, file_content)
    end
  end
end
