import Ecto.Query, warn: false
alias Counselling.Ranks.RankCutoff
alias Counselling.{Colleges, Colleges.College, Programs, Repo, NirfRanking, NirfRankings}

generated_college_data =
  "priv/static/generated_college_data.json"
  |> File.read!()
  |> Jason.decode!()

# Create Colleges
"lib/counselling/data/colleges/college-names.json"
|> File.read!()
|> Jason.decode!()
|> Map.get("colleges")
|> Enum.each(fn college_name ->
  # Get details for this college, or use empty map if not found
  details = Map.get(generated_college_data, college_name, %{})

  Colleges.create_college(%{
    name: String.trim(college_name) |> String.replace(~r/\s+/, " "),
    location: Map.get(details, "location"),
    established_year: Map.get(details, "established_year"),
    class: Colleges.class(college_name),
    website: Map.get(details, "official_website"),
    campus_area: Map.get(details, "campus_area_acres"),
    description: Map.get(details, "description"),
    photo_path: Map.get(details, "image_path")
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
    name: program["name"] |> String.trim() |> String.replace(~r/\s+/, " "),
    duration: program["duration"],
    degree_type: program["degree_type"]
  })
end)

IO.puts("Created #{Repo.aggregate(Programs.Program, :count)} programs successfully!")

# Create NIRF Ranks

colleges = Repo.all(from c in College, select: {c.id, c.name})

# Seed NIRF for all years with data files
nirf_years = [2023, 2024, 2025]

for year <- nirf_years,
    {college_id, college_name} <- colleges do
  {:ok, _created_rank} =
    NirfRankings.create_ranking(%{
      college_id: college_id,
      year: year,
      nirf_rank: NIRF.get_rank(college_name, year)
    })
end

IO.puts("Created #{Repo.aggregate(NirfRanking, :count)} rankings successfully!")

corrections =
  [
    {"National Institute of Technology, Tiruchirappalli", 2024, 9},
    {"Indian Institute of Technology (ISM) Dhanbad", 2024, 15},
    {"National Institute of Technology, Rourkela", 2024, 19},
    {"National Institute of Technology, Warangal", 2024, 21},
    {"Visvesvaraya National Institute of Technology, Nagpur", 2024, 39},
    {"National Institute of Technology, Silchar", 2024, 40},
    {"Malaviya National Institute of Technology Jaipur", 2024, 43},
    {"Dr. B R Ambedkar National Institute of Technology, Jalandhar", 2024, 58},
    {"Motilal Nehru National Institute of Technology Allahabad", 2024, 60},
    {"Maulana Azad National Institute of Technology Bhopal", 2024, 72},
    {"National Institute of Technology, Srinagar", 2024, 79},
    {"National Institute of Technology, Kurukshetra", 2024, 81},
    {"National Institute of Technology Agartala", 2024, 82},
    {"Indian Institute of Information Technology, Allahabad", 2024, 87},
    {"Atal Bihari Vajpayee Indian Institute of Information Technology and Management Gwalior",
     2024, 125},
    {"Indian Institute of Information Technology, Design and Manufacturing, Kancheepuram", 2024,
     125},
    {"National Institute of Food Technology Entrepreneurship and Management, Thanjavur", 2024,
     125},
    {"National Institute of Technology Arunachal Pradesh", 2024, 125},
    {"National Institute of Technology, Manipur", 2024, 125},
    {"National Institute of Technology, Mizoram", 2024, 125},
    {"National Institute of Technology, Uttarakhand", 2024, 125},
    {"Pt. Dwarka Prasad Mishra Indian Institute of Information Technology, Design and Manufacture Jabalpur",
     2024, 125},
    {"Punjab Engineering College, Chandigarh", 2024, 125},
    {"National Institute of Food Technology Entrepreneurship and Management, Kundli", 2024, 175},
    {"National Institute of Food Technology Entrepreneurship and Management, Kundli", 2023, 175},
    {"Shri Mata Vaishno Devi University, Katra, Jammu and Kashmir", 2024, 175},
    {"Shri Mata Vaishno Devi University, Katra, Jammu and Kashmir", 2023, 175},
    {"School of Engineering, Tezpur University, Napaam, Tezpur", 2024, 175},
    {"Indian Institute of Information Technology (IIIT) Ranchi", 2024, 175},
    {"Indian Institute of Information Technology Design and Manufacturing Kurnool, Andhra Pradesh",
     2024, 175},
    {"Indian Institute of Information Technology, Design and Manufacturing, Kancheepuram", 2024,
     175},
    {"National Institute of Technology, Tiruchirappalli", 2023, 9},
    {"National Institute of Technology, Rourkela", 2023, 16},
    {"Indian Institute of Technology (ISM) Dhanbad", 2023, 17},
    {"National Institute of Technology, Warangal", 2023, 21},
    {"Malaviya National Institute of Technology Jaipur", 2023, 37},
    {"National Institute of Technology, Silchar", 2023, 40},
    {"Indian Institute of Technology Patna", 2023, 42},
    {"Motilal Nehru National Institute of Technology Allahabad", 2023, 49},
    {"National Institute of Technology, Kurukshetra", 2023, 58},
    {"Indian Institute of Technology Tirupati", 2023, 59},
    {"Sardar Vallabhbhai National Institute of Technology, Surat", 2023, 65},
    {"National Institute of Technology Raipur", 2023, 70},
    {"Maulana Azad National Institute of Technology Bhopal", 2023, 80},
    {"National Institute of Technology, Srinagar", 2023, 82},
    {"Atal Bihari Vajpayee Indian Institute of Information Technology and Management Gwalior",
     2023, 88},
    {"Indian Institute of Information Technology, Allahabad", 2023, 89},
    {"National Institute of Technology Agartala", 2023, 91},
    {"Indian Institute of Technology Dharwad", 2023, 93},
    {"National Institute of Technology, Manipur", 2023, 95},
    {"Pt. Dwarka Prasad Mishra Indian Institute of Information Technology, Design and Manufacture Jabalpur",
     2023, 97},
    {"Indian Institute of Information Technology, Design and Manufacturing, Kancheepuram", 2023,
     125},
    {"National Institute of Food Technology Entrepreneurship and Management, Thanjavur", 2023,
     125},
    {"National Institute of Technology Arunachal Pradesh", 2023, 125},
    {"National Institute of Technology, Uttarakhand", 2023, 125},
    {"Punjab Engineering College, Chandigarh", 2023, 125},
    {"Sant Longowal Institute of Engineering and Technology", 2023, 175},
    # 2025 corrections
    {"National Institute of Technology, Tiruchirappalli", 2025, 9},
    {"National Institute of Technology, Rourkela", 2025, 13},
    {"Indian Institute of Technology (ISM) Dhanbad", 2025, 15},
    {"National Institute of Technology, Warangal", 2025, 28},
    {"Indian Institute of Technology Bhubaneswar", 2025, 39},
    {"Malaviya National Institute of Technology Jaipur", 2025, 42},
    {"Visvesvaraya National Institute of Technology, Nagpur", 2025, 44},
    {"National Institute of Technology Durgapur", 2025, 49},
    {"National Institute of Technology, Silchar", 2025, 50},
    {"National Institute of Technology Patna", 2025, 53},
    {"Dr. B R Ambedkar National Institute of Technology, Jalandhar", 2025, 55},
    {"Indian Institute of Technology Tirupati", 2025, 57},
    {"Motilal Nehru National Institute of Technology Allahabad", 2025, 62},
    {"Sardar Vallabhbhai National Institute of Technology, Surat", 2025, 66},
    {"National Institute of Technology, Srinagar", 2025, 73},
    {"Sant Longowal Institute of Engineering and Technology", 2025, 79},
    {"Maulana Azad National Institute of Technology Bhopal", 2025, 81},
    {"National Institute of Technology, Kurukshetra", 2025, 85},
    {"National Institute of Technology Raipur", 2025, 86},
    {"Atal Bihari Vajpayee Indian Institute of Information Technology and Management Gwalior",
     2025, 96},
    {"Indian Institute of Information Technology, Allahabad", 2025, 125},
    {"Pt. Dwarka Prasad Mishra Indian Institute of Information Technology, Design and Manufacture Jabalpur",
     2025, 125},
    {"Punjab Engineering College, Chandigarh", 2025, 125},
    {"National Institute of Food Technology Entrepreneurship and Management, Thanjavur", 2025, 125},
    {"Indian Institute of Information Technology, Design and Manufacturing, Kancheepuram", 2025, 125},
    {"School of Engineering, Tezpur University, Napaam, Tezpur", 2025, 175},
    {"Indian Institute of Information Technology Design and Manufacturing Kurnool, Andhra Pradesh",
     2025, 175},
    {"Indian Institute of Information Technology (IIIT) Ranchi", 2025, 175},
    {"National Institute of Food Technology Entrepreneurship and Management, Kundli", 2025, 175},
    {"Shri Mata Vaishno Devi University, Katra, Jammu and Kashmir", 2025, 175}
  ]

Enum.each(corrections, fn {college_name, year, rank} ->
  college = Repo.get_by(College, name: college_name)

  if college do
    NirfRankings.update_ranking(college_name, year, rank)
  end
end)

IO.puts("Finished nirf rank corrections...")

# Associate Programs and Colleges with cutoff data
errors =
  for year <- [2023, 2024, 2025] do
    Josaa.list_college_program_data(year)
    |> Enum.reduce([], fn row, acc ->
      case Colleges.process_table_row(row, year) do
        {:ok, _result} ->
          acc

        {:error, reason} ->
          [reason | acc]

        {:skip, reason} ->
          IO.puts("Skipped row: #{reason}")
          acc
      end
    end)
  end
  |> List.flatten()

IO.inspect(errors, label: "Errors found")
IO.puts("Created #{Repo.aggregate(RankCutoff, :count)} rank cutoffs successfully!")
