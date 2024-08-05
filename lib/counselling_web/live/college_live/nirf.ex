defmodule NIRF do
  def get_rank_and_score(data, college_name) do
    Enum.find_value(data, fn
      {"tr", _, [_, {"td", _, [^college_name | _]}, _, _, {"td", _, _}, {"td", _, [rank]}]} ->
        rank

      _ ->
        125
    end)
  end

  def get_ranks(college) do
    {:ok, document} =
      File.read!("lib/counselling_web/live/EngineeringRanking.html")
      |> Floki.parse_document()

    document
    |> Floki.find("#tbl_overall")
    |> Floki.find("tr")
    |> get_rank_and_score(college)
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
