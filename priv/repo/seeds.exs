import Ecto.Query, warn: false

alias Counselling.{
  CollegePrograms.CollegeProgram,
  Colleges,
  Colleges.College,
  NirfRanking,
  Programs.Program,
  Repo,
  Ranks.RankCutoff
}

defmodule Counselling.Seeds.Helpers do
  @college_aliases %{
    "Indian Institute of Information Technology Manipur" =>
      "INDIAN INSTITUTE OF INFORMATION TECHNOLOGY SENAPATI MANIPUR",
    "Institute of Technology, Guru Ghasidas Vishwavidyalaya (A Central University), Bilaspur, (C.G.)" =>
      "School of Studies of Engineering and Technology, Guru Ghasidas Vishwavidyalaya, Bilaspur"
  }

  def now, do: NaiveDateTime.utc_now(:second)

  def normalize_name(value) do
    value
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  def normalize_josaa_name(value) do
    value
    |> normalize_name()
    |> String.replace("&", "and")
  end

  def canonical_college_name(value) do
    normalized = normalize_josaa_name(value)
    Map.get(@college_aliases, normalized, normalized)
  end

  def college_slug(name) do
    name
    |> String.downcase()
    |> String.replace([" ", "  "], "-")
    |> String.replace(",", "")
  end

  def program_slug(name) do
    name
    |> String.downcase()
    |> String.replace(" ", "-")
  end

  def program_key(program_name) do
    details =
      program_name
      |> normalize_josaa_name()
      |> Josaa.parse_degree_info()

    case details do
      %{name: name, duration: duration, degree_type: degree_type} ->
        {name, duration, degree_type}

      _ ->
        nil
    end
  end

  def parse_cutoff_row(row, year) do
    case row do
      {"tr", [{"class", "text-white bg-secondary"}], _} ->
        {:skip, "Skipping header row"}

      {"tr", _, [{"th", _, _} | _]} ->
        {:skip, "Skipping header row"}

      {"tr", _, data} when length(data) == 7 ->
        [college_name, program_name, quota, seat_type, gender, opening_rank, closing_rank] =
          Enum.map(data, &Colleges.extract_row_content/1)

        values = [
          college_name,
          program_name,
          quota,
          seat_type,
          gender,
          opening_rank,
          closing_rank
        ]

        if Enum.any?(values, &(&1 == "")) do
          {:skip, "Skipping row with empty fields"}
        else
          {:ok,
           %{
             college_name: college_name,
             canonical_college_name: canonical_college_name(college_name),
             program_name: program_name,
             program_key: program_key(program_name),
             quota: Colleges.parse_quota(quota),
             seat_type: Josaa.seat_type_atom(seat_type),
             gender: Colleges.parse_gender(gender),
             opening_rank: Colleges.parse_rank(opening_rank),
             closing_rank: Colleges.parse_rank(closing_rank),
             year: year
           }}
        end

      _ ->
        {:error, "Invalid row format"}
    end
  end
end

helpers = Counselling.Seeds.Helpers
now = helpers.now()
seed_years = [2023, 2024, 2025]

parsed_results =
  seed_years
  |> Task.async_stream(
    fn year ->
      year
      |> Josaa.list_college_program_data()
      |> Enum.map(&helpers.parse_cutoff_row(&1, year))
    end,
    max_concurrency: System.schedulers_online(),
    timeout: :infinity
  )
  |> Enum.flat_map(fn {:ok, results} -> results end)

generated_college_data =
  "priv/static/generated_college_data.json"
  |> File.read!()
  |> Jason.decode!()

college_names_from_rank_files =
  parsed_results
  |> Enum.flat_map(fn
    {:ok, row} -> [row.canonical_college_name]
    _ -> []
  end)

college_rows =
  "lib/counselling/data/colleges/college-names.json"
  |> File.read!()
  |> Jason.decode!()
  |> Map.get("colleges")
  |> Enum.map(&helpers.normalize_name/1)
  |> Enum.concat(college_names_from_rank_files)
  |> Enum.uniq()
  |> Enum.map(fn college_name ->
    details = Map.get(generated_college_data, college_name, %{})

    %{
      name: college_name,
      location: Map.get(details, "location"),
      established_year: Map.get(details, "established_year"),
      class: Colleges.class(college_name),
      website: Map.get(details, "official_website"),
      campus_area: Map.get(details, "campus_area_acres"),
      description: Map.get(details, "description"),
      photo_path: Map.get(details, "image_path"),
      slug: helpers.college_slug(college_name),
      inserted_at: now,
      updated_at: now
    }
  end)
  |> Enum.filter(fn row ->
    row.name && row.established_year && row.location && row.class && row.description
  end)

Repo.insert_all(College, college_rows,
  on_conflict: :nothing,
  conflict_target: [:name]
)

IO.puts("Created #{Repo.aggregate(College, :count)} colleges successfully!")

program_rows_from_rank_files =
  parsed_results
  |> Enum.flat_map(fn
    {:ok, %{program_key: {name, duration, degree_type}}} ->
      [%{"name" => name, "duration" => duration, "degree_type" => degree_type}]

    _ ->
      []
  end)

program_rows =
  "lib/counselling/data/programs/program-names.json"
  |> File.read!()
  |> Jason.decode!()
  |> Map.get("programs")
  |> Enum.concat(program_rows_from_rank_files)
  |> Enum.uniq_by(&{&1["name"], &1["duration"], &1["degree_type"]})
  |> Enum.map(fn program ->
    name = helpers.normalize_name(program["name"])

    %{
      name: name,
      duration: program["duration"],
      degree_type: program["degree_type"],
      slug: helpers.program_slug(name),
      inserted_at: now,
      updated_at: now
    }
  end)

Repo.insert_all(Program, program_rows,
  on_conflict: :nothing,
  conflict_target: [:name, :duration, :degree_type]
)

IO.puts("Created #{Repo.aggregate(Program, :count)} programs successfully!")

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
    {"National Institute of Food Technology Entrepreneurship and Management, Thanjavur", 2025,
     125},
    {"Indian Institute of Information Technology, Design and Manufacturing, Kancheepuram", 2025,
     125},
    {"School of Engineering, Tezpur University, Napaam, Tezpur", 2025, 175},
    {"Indian Institute of Information Technology Design and Manufacturing Kurnool, Andhra Pradesh",
     2025, 175},
    {"Indian Institute of Information Technology (IIIT) Ranchi", 2025, 175},
    {"National Institute of Food Technology Entrepreneurship and Management, Kundli", 2025, 175},
    {"Shri Mata Vaishno Devi University, Katra, Jammu and Kashmir", 2025, 175}
  ]

nirf_years = seed_years

college_lookup =
  Repo.all(from c in College, select: {c.name, c.id})
  |> Map.new()

rankings_by_year =
  Map.new(nirf_years, fn year ->
    rankings =
      case File.read("lib/counselling/data/colleges/nirf/#{year}/rankings.json") do
        {:ok, content} ->
          content
          |> Jason.decode!()
          |> Map.new(&{&1["college"], &1["rank"]})

        _ ->
          %{}
      end

    {year, rankings}
  end)

corrections_by_college_year =
  corrections
  |> Enum.filter(fn {college_name, _year, _rank} ->
    Map.has_key?(college_lookup, college_name)
  end)
  |> Map.new(fn {college_name, year, rank} -> {{college_lookup[college_name], year}, rank} end)

nirf_rows =
  for {college_name, college_id} <- college_lookup,
      year <- nirf_years do
    rank =
      Map.get(corrections_by_college_year, {college_id, year}) ||
        get_in(rankings_by_year, [year, college_name]) ||
        500

    %{
      college_id: college_id,
      year: year,
      nirf_rank: rank,
      inserted_at: now,
      updated_at: now
    }
  end

Repo.delete_all(from nr in NirfRanking, where: nr.year in ^nirf_years)
Repo.insert_all(NirfRanking, nirf_rows)

IO.puts("Created #{Repo.aggregate(NirfRanking, :count)} rankings successfully!")
IO.puts("Finished nirf rank corrections...")

program_lookup =
  Repo.all(from p in Program, select: {{p.name, p.duration, p.degree_type}, p.id})
  |> Map.new()

errors =
  parsed_results
  |> Enum.flat_map(fn
    {:error, reason} ->
      [reason]

    {:ok, %{program_key: nil, program_name: program_name}} ->
      ["Program not found: #{program_name}"]

    {:ok, row} ->
      cond do
        !Map.has_key?(college_lookup, row.canonical_college_name) ->
          ["College not found: #{row.college_name}"]

        !Map.has_key?(program_lookup, row.program_key) ->
          ["Program not found: #{row.program_name}"]

        true ->
          []
      end

    {:skip, reason} ->
      IO.puts("Skipped row: #{reason}")
      []
  end)

valid_rows =
  parsed_results
  |> Enum.flat_map(fn
    {:ok, row} ->
      college_id = Map.get(college_lookup, row.canonical_college_name)
      program_id = Map.get(program_lookup, row.program_key)

      if college_id && program_id do
        [Map.merge(row, %{college_id: college_id, program_id: program_id})]
      else
        []
      end

    _ ->
      []
  end)

college_program_rows =
  valid_rows
  |> Enum.map(
    &%{college_id: &1.college_id, program_id: &1.program_id, inserted_at: now, updated_at: now}
  )
  |> Enum.uniq_by(&{&1.college_id, &1.program_id})

college_program_rows
|> Enum.chunk_every(1_000)
|> Enum.each(fn rows ->
  Repo.insert_all(CollegeProgram, rows,
    on_conflict: :nothing,
    conflict_target: [:college_id, :program_id]
  )
end)

college_program_lookup =
  Repo.all(from cp in CollegeProgram, select: {{cp.college_id, cp.program_id}, cp.id})
  |> Map.new()

rank_cutoff_rows =
  valid_rows
  |> Enum.map(fn row ->
    college_program_id = college_program_lookup[{row.college_id, row.program_id}]

    %{
      opening_rank: row.opening_rank,
      closing_rank: row.closing_rank,
      quota: row.quota,
      gender: row.gender,
      seat_type: row.seat_type,
      year: row.year,
      college_program_id: college_program_id,
      inserted_at: now,
      updated_at: now
    }
  end)
  |> Enum.reject(&is_nil(&1.college_program_id))
  |> Enum.uniq_by(&{&1.year, &1.college_program_id, &1.quota, &1.gender, &1.seat_type})

rank_cutoff_rows
|> Enum.chunk_every(1_000)
|> Enum.each(fn rows ->
  Repo.insert_all(RankCutoff, rows,
    on_conflict: {:replace, [:opening_rank, :closing_rank, :updated_at]},
    conflict_target: [:year, :college_program_id, :quota, :gender, :seat_type]
  )
end)

IO.inspect(errors, label: "Errors found")
IO.puts("Created #{Repo.aggregate(RankCutoff, :count)} rank cutoffs successfully!")
