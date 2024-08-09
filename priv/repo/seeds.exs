# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Counselling.Repo.insert!(%Counselling.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# In seeds.exs
alias Counselling.Colleges

# Create colleges
colleges =
  "lib/counselling_web/live/college-names.json" |> File.read!() |> Jason.decode!()

ranking_map1 = NIRF.get_college_rank_data() |> NIRF.create_ranking_map()
ranking_map2 = NIRF.get_college_rank_data_second() |> NIRF.create_ranking_map_150()
ranking_map3 = NIRF.get_college_rank_data_third() |> NIRF.create_ranking_map_200()

defmodule CRanks do
  def get_rank(ranking_map1, ranking_map2, ranking_map3, college_name) do
    cond do
      NIRF.find_college_rank(ranking_map1, college_name) != nil ->
        NIRF.find_college_rank(ranking_map1, college_name)

      NIRF.find_college_rank(ranking_map2, college_name) != nil ->
        NIRF.find_college_rank(ranking_map2, college_name)

      NIRF.find_college_rank(ranking_map3, college_name) != nil ->
        NIRF.find_college_rank(ranking_map3, college_name)

      true ->
        500
    end
  end
end

_created_colleges =
  Enum.map(colleges["colleges"], fn college ->
    {:ok, _created_college} =
      Colleges.create_college(%{
        name: college["name"],
        class: Colleges.get_class(college["name"]),
        nirfrank: CRanks.get_rank(ranking_map1, ranking_map2, ranking_map3, college["name"])
      })
  end)

IO.puts("All Colleges created successfully!")

###########
# Create programs

programs =
  "lib/counselling_web/live/program-names.json" |> File.read!() |> Jason.decode!() |> dbg()

_created_programs =
  Enum.map(programs["programs"], fn
    program ->
      Colleges.create_program(%{
        name: program["name"],
        duration: program["duration"],
        degree_type: program["program"]
      })
  end)

IO.puts("All Programs created successfully!")

table_rows = Josaa.colleges_list()

table_rows
|> Enum.each(fn row ->
  case Colleges.process_table_row(row) do
    {:ok, _result} -> IO.puts("Row processed successfully")
    {:error, reason} -> IO.puts("Error processing row: #{inspect(reason)}")
    {:skip, reason} -> IO.puts("Skipped row: #{reason}")
  end
end)

IO.puts("Seeding completed successfully!")
