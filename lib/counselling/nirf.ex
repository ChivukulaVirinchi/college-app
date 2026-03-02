defmodule NIRF do
  def html_to_json(year) do
    official_names =
      "lib/counselling/data/colleges/college-names.json"
      |> File.read!()
      |> Jason.decode!()
      |> Map.get("colleges")
      |> MapSet.new()

    rankings =
      "lib/counselling/data/colleges/nirf/#{year}"
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".html"))
      |> Enum.map(&Path.join("lib/counselling/data/colleges/nirf/#{year}", &1))
      |> Enum.flat_map(&parse_file(&1, official_names))
      |> Enum.reject(&is_nil(&1))

    json = Jason.encode!(rankings, pretty: true)
    File.write!("lib/counselling/data/colleges/nirf/#{year}/rankings.json", json)
  end

  defp parse_file(path, official_names) do
    case File.read(path) do
      {:ok, html} ->
        {:ok, doc} = Floki.parse_document(html)
        parse_html(doc, get_rank_type(path), official_names)

      _ ->
        []
    end
  end

  defp get_rank_type(path) do
    cond do
      String.contains?(path, "300") -> 250
      String.contains?(path, "200") -> 175
      String.contains?(path, "150") -> 125
      true -> :top100
    end
  end

  defp parse_html(doc, :top100, official_names) do
    doc
    |> Floki.find("table#tbl_overall tbody tr")
    |> Enum.map(fn {"tr", _, cells} ->
      case cells do
        [_, {"td", _, [name | _]}, _, _, _, {"td", _, [rank]}] ->
          create_entry(name, rank, official_names)

        _ ->
          nil
      end
    end)
  end

  defp parse_html(doc, rank, official_names) do
    doc
    |> Floki.find("table.table tbody tr")
    |> Enum.map(fn {"tr", _, cells} ->
      case cells do
        [{"td", _, [name | _]} | _] ->
          create_entry(name, to_string(rank), official_names)

        _ ->
          nil
      end
    end)
  end

  defp create_entry(name, rank, official_names) do
    college_name =
      String.trim(name)
      |> String.replace(~r/\s+/, " ")
      |> String.replace("(Banaras Hindu University)", "(BHU)")
      |> String.replace("(Indian School of Mines)", "(ISM) Dhanbad")
      |> String.replace("Deemed-to-be-university", "")
      |> String.replace("&", "and")
      |> String.trim()

    case Enum.find(official_names, &String.equivalent?(&1, college_name)) do
      nil ->
        nil

      official_name ->
        %{
          "college" => official_name,
          "rank" => String.trim(rank) |> String.to_integer()
        }
    end
  end

  def get_rank(college_name, year) do
    with {:ok, content} <- File.read("lib/counselling/data/colleges/nirf/#{year}/rankings.json"),
         {:ok, rankings} <- Jason.decode(content),
         entry when not is_nil(entry) <- Enum.find(rankings, &(&1["college"] == college_name)) do
      entry["rank"]
    else
      _ -> 500
    end
  end
end
