file_path = "/real_estate_auctions/tmp/caixa_lista_CE_01112024_232455-0300.csv"

# {:ok, file} = File.open(file_path, [:read, :binary]) # desse jeito os caracteres são lidos normalmente
# IO.read(file, :line)

# File.stream!(file_path, [:trim_bom]) |> CSV.decode(separator: ?;, field_transform: &String.trim/1) |> Enum.take(5)


# File.stream!(file_path, [:trim_bom])
# |> CSV.decode(separator: ?;, field_transform: fn field ->
#   if String.valid?(field) do
#     field
#   else
#     field
#     |> String.codepoints()
#     |> Enum.map(fn codepoint -> if String.valid?(codepoint), do: codepoint, else: "?" end)
#     |> Enum.join()
#   end
#   |> String.trim()
# end)
# |> Enum.take(5)

# File.open!(file_path, [:read, :binary]) |> CSV.decode(separator: ?;, field_transform: &String.trim/1)

####################### VERSAO FINAL #######################
{:ok, file} = File.open(file_path, [:read, :binary])

# file |> IO.stream(:line) |> CSV.decode!(separator: ?;, field_transform: &String.trim/1) |> Stream.each(&IO.puts/1) |> Stream.run
file |> IO.stream(:line) |> CSV.decode!(separator: ?;, field_transform: &String.trim/1) |> Enum.to_list

File.close(file)
