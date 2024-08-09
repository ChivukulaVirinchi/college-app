defmodule NIRF do
  def get_college_rank_data() do
    File.read!("lib/counselling_web/live/EngineeringRanking.html")
    |> Floki.parse_document!()
    |> Floki.find("#tbl_overall")
    |> Floki.find("tr")
    |> tl()
  end

  def get_college_rank_data_second() do
    File.read!("lib/counselling_web/live/EngineeringRanking150.html")
    |> Floki.parse_document!()
    |> Floki.find(".table")
    |> Floki.find("tbody")
    |> Floki.find("tr")
  end

  def get_college_rank_data_third() do
    File.read!("lib/counselling_web/live/EngineeringRanking200.html")
    |> Floki.parse_document!()
    |> Floki.find(".table")
    |> Floki.find("tbody")
    |> Floki.find("tr")
  end

  def create_ranking_map_150(data) do
    Enum.reduce(data, %{}, fn {"tr", _, [{"td", _, [college_name]}, _, _]}, acc ->
      Map.put(acc, college_name, 125)
    end)
  end

  def create_ranking_map_200(data) do
    Enum.reduce(data, %{}, fn {"tr", _, [{"td", _, [college_name]}, _, _]}, acc ->
      Map.put(acc, college_name, 175)
    end)
  end

  def create_ranking_map(data) do
    Enum.reduce(data, %{}, fn
      {"tr", [], cells}, acc ->
        case extract_college_info(cells) do
          {college_name, rank} -> Map.put(acc, college_name, rank)
          _ -> acc
        end

      _, acc ->
        acc
    end)
  end

  defp extract_college_info(cells) do
    college_cell = Enum.at(cells, 1)
    rank_cell = List.last(cells)

    with {"td", [], [college_name | _]} <- college_cell,
         {"td", [], [rank]} <- rank_cell do
      {normalize_college_name(college_name), rank}
    else
      _ -> nil
    end
  end

  defp normalize_college_name(name) do
    name
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
    |> String.replace(~r/[(),]/, "")
    |> String.replace("banaras hindu university", "bhu")
    |> String.replace("indian school of mines", "ism")
    |> String.replace("karnataka surathkal", "surathkal")
  end

  def find_college_rank(ranking_map, college_name) do
    normalized_name = normalize_college_name(college_name)

    Enum.find_value(ranking_map, fn {key, rank} ->
      if college_names_match?(key, normalized_name), do: rank
    end)
  end

  defp college_names_match?(name1, name2) do
    normalized1 = normalize_college_name(name1)
    normalized2 = normalize_college_name(name2)

    cond do
      normalized1 == normalized2 -> true
      String.contains?(normalized1, normalized2) -> true
      String.contains?(normalized2, normalized1) -> true
      true -> false
    end
  end

  # def count(data) do
  #   Enum.count(data, fn
  #     {"tr", _, [_, {"td", _, [college_name | _]}, _, _, {"td", _, _}, {"td", _, _}]} ->
  #       String.contains?(college_name, [
  #         "Indian Institute of Technology",
  #         "Indian Institute of Information Technology",
  #         "National Institute of Technology"
  #       ])

  #     _ ->
  #       nil
  #   end)
  # end

  # def count_clgs() do
  #   {:ok, document} =
  #     Req.get!("https://www.nirfindia.org/Rankings/2023/EngineeringRanking.html").body
  #     |> Floki.parse_document()

  #   document
  #   |> Floki.find("#tbl_overall")
  #   |> Floki.find("tr")
  #   # |> dbg()

  #   |> count()
  # end
end
