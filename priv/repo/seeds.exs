import Ecto.Query, warn: false
alias Counselling.Ranks.RankCutoff
alias Counselling.{Colleges, Colleges.College, Programs, Repo, NirfRanking, NirfRankings}
# Create Colleges
"lib/counselling/data/colleges/college-names.json"
|> File.read!()
|> Jason.decode!()
|> Map.get("colleges")
|> Enum.each(fn college_name ->
  Colleges.create_college(%{
    name: String.trim(college_name),
    class: Colleges.class(college_name)
  })
end)

IO.puts("Created #{Repo.aggregate(Colleges.College, :count)} colleges successfully!")

# Create Programs
"lib/counselling/data/programs/program-names.json"
|> File.read!()
|> Jason.decode!()
|> Map.get("programs")
|> Enum.each(fn program ->
  Programs.create_program(%{
    name: String.trim(program["name"]),
    duration: program["duration"],
    degree_type: program["degree_type"]
  })
end)

IO.puts("Created #{Repo.aggregate(Programs.Program, :count)} programs successfully!")

# Create NIRF Ranks

colleges = Repo.all(from c in College, select: {c.id, c.name})

for year <- [2023, 2024],
    {college_id, college_name} <- colleges do
  {:ok, _created_rank} =
    NirfRankings.create_ranking(%{
      college_id: college_id,
      year: year,
      nirf_rank: NIRF.get_rank(college_name, year)
    })
end

IO.puts("Created #{Repo.aggregate(NirfRanking, :count)} rankings successfully!")

# Associate Programs and Colleges
errors = []

for year <- [2023, 2024] do
  Josaa.list_college_program_data(year)
  |> Enum.each(fn row ->
    case Colleges.process_table_row(row, year) do
      {:ok, _result} -> :ok
      {:error, reason} -> IO.puts("row error: #{reason}")
      {:skip, reason} -> IO.puts("Skipped row: #{reason}")
    end
  end)
end

IO.inspect(errors)
IO.puts("Created #{Repo.aggregate(RankCutoff, :count)} rank cutoffs successfully!")
