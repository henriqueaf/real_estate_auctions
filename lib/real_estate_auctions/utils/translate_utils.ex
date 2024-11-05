defmodule RealEstateAuctions.TranslateUtils do
  def translate_errors(%{} = changeset) do
    errors_map = Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)

    Enum.map(errors_map, fn {k, v} -> "#{k} #{v}" end)
  end
end
