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

_created_colleges =
  Enum.map(colleges["colleges"], fn college ->
    {:ok, created_college} =
      Colleges.create_college(%{
        name: college["name"] |> String.trim(),
        class: Colleges.get_class(college["name"])
      })

    # {:ok, _created_rank} =
    #   Colleges.create_nirf_ranking(%{
    #     college_id: created_college.id,
    #     year: 2023,
    #     nirf_rank: CRanks.get_rank(ranking_map1, ranking_map2, ranking_map3, created_college.name)
    #   })
  end)

IO.puts("All Colleges created successfully!")

# Create NIRF rankings

for year <- [2023, 2024] do
  ranking_map1 = NIRF.get_college_rank_data(year) |> NIRF.create_ranking_map()
  ranking_map2 = NIRF.get_college_rank_data_second(year) |> NIRF.create_ranking_map_150()
  ranking_map3 = NIRF.get_college_rank_data_third(year) |> NIRF.create_ranking_map_200()

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

  for college <- Colleges.list_colleges() do
    {:ok, _created_rank} =
      Colleges.create_nirf_ranking(%{
        college_id: college.id,
        year: year,
        nirf_rank: CRanks.get_rank(ranking_map1, ranking_map2, ranking_map3, college.name)
      })
  end
end

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
