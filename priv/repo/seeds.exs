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
alias Counselling.Repo
alias Counselling.Colleges.College
alias Counselling.Programs.Program

# Create colleges
colleges =
  "lib/counselling_web/live/college-names.json" |> File.read!() |> Jason.decode!()

_created_colleges =
  Enum.map(colleges["colleges"], fn college ->
    {:ok, _created_college} =
      Repo.insert(%College{
        name: college["name"],
        class: Colleges.get_class(college["name"]),
        nirfrank: NIRF.get_ranks(college["name"])
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
