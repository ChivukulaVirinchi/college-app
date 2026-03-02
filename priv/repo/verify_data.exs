# Post-seed data integrity verification
# Run: mix run priv/repo/verify_data.exs

import Ecto.Query

alias Counselling.{
  Colleges,
  Colleges.College,
  CollegePrograms.CollegeProgram,
  NirfRanking,
  Programs.Program,
  Ranks.RankCutoff,
  Repo
}

latest_year = Josaa.latest_year()
IO.puts("\n=== DATA INTEGRITY VERIFICATION (#{latest_year}) ===\n")

failures = []

# 1. College counts
college_count = Repo.aggregate(College, :count)
listing_count = Colleges.list_colleges() |> Repo.all() |> length()
IO.puts("[Colleges] DB: #{college_count}, Listing: #{listing_count}")

failures =
  if listing_count < college_count * 0.9 do
    msg = "Only #{listing_count}/#{college_count} colleges visible in listing"
    IO.puts("  FAIL: #{msg}")
    [msg | failures]
  else
    IO.puts("  OK: #{Float.round(listing_count / college_count * 100, 1)}% visible")
    failures
  end

# 2. Program count
program_count = Repo.aggregate(Program, :count)
IO.puts("[Programs] #{program_count}")

# 3. Rank cutoffs per year
IO.puts("[Rank Cutoffs]")

failures =
  Enum.reduce([2023, 2024, latest_year], failures, fn year, acc ->
    count = from(rc in RankCutoff, where: rc.year == ^year) |> Repo.aggregate(:count)
    IO.puts("  #{year}: #{count}")

    if count < 5_000 do
      msg = "Year #{year} has only #{count} cutoffs (expected >5k)"
      IO.puts("  FAIL: #{msg}")
      [msg | acc]
    else
      acc
    end
  end)

# 4. NIRF coverage
nirf_count = from(nr in NirfRanking, where: nr.year == ^latest_year) |> Repo.aggregate(:count)
IO.puts("[NIRF Rankings] #{latest_year}: #{nirf_count}")

colleges_without_nirf =
  from(c in College,
    left_join: nr in NirfRanking,
    on: nr.college_id == c.id and nr.year == ^latest_year,
    where: is_nil(nr.id),
    select: c.name
  )
  |> Repo.all()

failures =
  if length(colleges_without_nirf) > 0 do
    msg = "#{length(colleges_without_nirf)} colleges missing #{latest_year} NIRF"
    IO.puts("  WARN: #{msg}: #{inspect(Enum.take(colleges_without_nirf, 5))}")
    failures
  else
    IO.puts("  OK: All colleges have #{latest_year} NIRF rankings")
    failures
  end

# 5. College-Program cutoff coverage
total_cps = Repo.aggregate(CollegeProgram, :count)

cps_with_cutoffs =
  from(cp in CollegeProgram,
    join: rc in RankCutoff,
    on: rc.college_program_id == cp.id,
    where: rc.year == ^latest_year,
    distinct: cp.id,
    select: cp.id
  )
  |> Repo.all()
  |> length()

coverage = if total_cps > 0, do: cps_with_cutoffs / total_cps * 100, else: 0
IO.puts("[College-Program Coverage] #{cps_with_cutoffs}/#{total_cps} (#{Float.round(coverage, 1)}%)")

failures =
  if coverage < 70 do
    msg = "College-program cutoff coverage below 70%: #{Float.round(coverage, 1)}%"
    IO.puts("  FAIL: #{msg}")
    [msg | failures]
  else
    IO.puts("  OK")
    failures
  end

# 6. Spot check key colleges
IO.puts("\n[Spot Checks]")

spot_checks = [
  {"Pt. Dwarka Prasad Mishra Indian Institute of Information Technology, Design and Manufacture Jabalpur",
   "IIIT Jabalpur"},
  {"Indian Institute of Technology Bombay", "IIT Bombay"},
  {"National Institute of Technology, Tiruchirappalli", "NIT Trichy"},
  {"Atal Bihari Vajpayee Indian Institute of Information Technology and Management Gwalior",
   "ABV IIITM Gwalior"}
]

for {name, short} <- spot_checks do
  college = Repo.get_by(College, name: name)

  if college do
    rc_count =
      from(rc in RankCutoff,
        join: cp in CollegeProgram,
        on: cp.id == rc.college_program_id,
        where: cp.college_id == ^college.id and rc.year == ^latest_year
      )
      |> Repo.aggregate(:count)

    nirf =
      Repo.one(
        from(nr in NirfRanking,
          where: nr.college_id == ^college.id and nr.year == ^latest_year
        )
      )

    status = if rc_count > 0, do: "OK", else: "FAIL"
    IO.puts("  #{status}: #{short} — #{rc_count} cutoffs, NIRF #{if nirf, do: nirf.nirf_rank, else: "N/A"}")
  else
    IO.puts("  FAIL: #{short} not found in DB")
  end
end

# Summary
IO.puts("\n=== SUMMARY ===")

if failures == [] do
  IO.puts("ALL CHECKS PASSED")
else
  IO.puts("#{length(failures)} FAILURES:")
  Enum.each(failures, &IO.puts("  - #{&1}"))
  System.halt(1)
end
