defmodule RealEstateAuctions.AuctionsServices.CaixaService.CSVParser do
  @doc """
  Returns only the generate date info from CSV file.
  It accepts a file path as param or the csv content as string/binary.

  ## Examples

    iex> RealEstateAuctions.AuctionsServices.CaixaService.CSVParser.get_generate_date("/path/to/csv/file.csv")
    "01/11/2024"

    iex> RealEstateAuctions.AuctionsServices.CaixaService.CSVParser.get_generate_date("\n Lista de Imóveis da Caixa;;Data de geração:;01/11/2024;;;;;;;")
    "01/11/2024"

  """
  def get_generate_date(file_path_or_csv_content) do
    csv_to_list(file_path_or_csv_content)
    |> Enum.at(1) # returns the csv line that contains the generate date
    |> Enum.at(3) # returns the column value with the actual generate date
  end

  @doc """
  Returns just the auctions lines from CSV file, excluding headers
  and other info before headers.
  It accepts a file path as param or the csv content as string/binary.

  ## Examples

    iex> RealEstateAuctions.AuctionsServices.CaixaService.CSVParser.get_auctions_list("/path/to/csv/file.csv")
    [
      %{
        estimated_price: "138.000,00",
        state: "CE",
        address: "TRAVESSA EUROPA  , A, N. 20A",
        description: "Casa, 0.00 de área total, 61.07 de área privativa, 113.60 de área do terreno.",
        number: "8444416386866",
        city: "ABAIARA",
        neighborhood: "VERTENTE",
        start_price: "76.253,02",
        discount_percent: "44.75",
        sale_mode: "Venda Direta Online",
        address_link: "https://venda-imoveis.caixa.gov.br/sistema/detalhe-imovel.asp?hdnOrigem=index&hdnimovel=8444416386866"
      }
    ]

  """
  def get_auctions_list(file_path_or_csv_content) do
    csv_to_list(file_path_or_csv_content)
    |> Enum.slice(4..-1//1)
    |> Enum.map(fn line -> Enum.zip(csv_headers(), line) |> Map.new end)
  end

  defp csv_to_list(file_path_or_csv_content) do
    case String.ends_with?(file_path_or_csv_content, [".csv", ".CSV"]) do
      true -> csv_file_to_list(file_path_or_csv_content)
      false -> csv_content_to_list(file_path_or_csv_content)
    end
  end

  defp csv_headers() do
    ~w{number state city neighborhood address start_price estimated_price discount_percent description sale_mode address_link}a
  end

  defp csv_file_to_list(file_path) do
    file_io_pid = File.open!(file_path, [:read, :binary])

    try do
      file_io_pid
      |> IO.stream(:line)
      |> CSV.decode!(separator: ?;, field_transform: &String.trim/1)
      |> Enum.to_list
    after
      File.close(file_io_pid)
    end
  end

  defp csv_content_to_list(csv_content) do
    raw_content = validate_csv_content(csv_content)

    {:ok, string_io_pid} = raw_content |> StringIO.open()

    try do
      string_io_pid
      |> IO.binstream(:line)
      |> CSV.decode!(separator: ?;, field_transform: &String.trim/1)
      |> Enum.to_list
    after
      StringIO.close(string_io_pid)
    end
  end

  defp validate_csv_content(csv_content) do
    case String.valid?(csv_content) do
      true -> csv_content
      false -> List.to_string(:unicode.characters_to_list(csv_content, :latin1))
      # false -> List.to_string(:binary.bin_to_list(csv_content))
    end
  end
end
