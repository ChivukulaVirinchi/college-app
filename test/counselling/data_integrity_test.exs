defmodule Counselling.DataIntegrityTest do
  @moduledoc """
  Data integrity tests for JOSAA/NIRF data files and name normalization.

  File-based tests run without DB. For full post-seed verification, run:
    mix run priv/repo/verify_data.exs
  """
  use ExUnit.Case, async: true

  describe "data files" do
    test "college-names.json is valid and has entries" do
      data =
        "lib/counselling/data/colleges/college-names.json"
        |> File.read!()
        |> Jason.decode!()
        |> Map.get("colleges")

      assert is_list(data)
      assert length(data) >= 120, "Expected >= 120 colleges, got #{length(data)}"

      # No duplicates
      assert length(data) == length(Enum.uniq(data)),
             "Duplicate college names found"
    end

    test "program-names.json is valid and has entries" do
      data =
        "lib/counselling/data/programs/program-names.json"
        |> File.read!()
        |> Jason.decode!()
        |> Map.get("programs")

      assert is_list(data)
      assert length(data) >= 230, "Expected >= 230 programs, got #{length(data)}"

      # All programs have required fields
      Enum.each(data, fn p ->
        assert Map.has_key?(p, "name"), "Program missing name: #{inspect(p)}"
        assert Map.has_key?(p, "duration"), "Program missing duration: #{inspect(p)}"
        assert Map.has_key?(p, "degree_type"), "Program missing degree_type: #{inspect(p)}"
      end)
    end

    test "rankings.json exists for all years" do
      for year <- [2023, 2024, 2025] do
        path = "lib/counselling/data/colleges/nirf/#{year}/rankings.json"
        assert File.exists?(path), "Missing #{path}"

        rankings = path |> File.read!() |> Jason.decode!()
        assert is_list(rankings)
        assert length(rankings) > 20, "#{path} has only #{length(rankings)} entries (expected >20)"

        # All entries have required fields
        Enum.each(rankings, fn entry ->
          assert Map.has_key?(entry, "college"), "Entry missing college: #{inspect(entry)}"
          assert Map.has_key?(entry, "rank"), "Entry missing rank: #{inspect(entry)}"
          assert is_integer(entry["rank"]), "Rank not integer: #{inspect(entry)}"
        end)
      end
    end

    test "JOSAA HTML files exist for all years" do
      for {year, file} <- [{2023, "JoSAA.html"}, {2024, "JoSAA.html"}, {2025, "JOSAA.html"}] do
        path = "lib/counselling/data/programs/ranks/#{year}/#{file}"
        assert File.exists?(path), "Missing #{path}"
      end
    end

    test "all NIRF ranked colleges exist in college-names.json" do
      college_names =
        "lib/counselling/data/colleges/college-names.json"
        |> File.read!()
        |> Jason.decode!()
        |> Map.get("colleges")
        |> MapSet.new()

      for year <- [2023, 2024, 2025] do
        rankings =
          "lib/counselling/data/colleges/nirf/#{year}/rankings.json"
          |> File.read!()
          |> Jason.decode!()

        missing =
          Enum.reject(rankings, fn entry ->
            MapSet.member?(college_names, entry["college"])
          end)

        assert missing == [],
               "#{year} rankings.json has colleges not in college-names.json: #{inspect(Enum.map(missing, & &1["college"]))}"
      end
    end
  end

  describe "JOSAA name resolution" do
    test "all JOSAA colleges can be resolved via get_college_id after normalization" do
      college_names =
        "lib/counselling/data/colleges/college-names.json"
        |> File.read!()
        |> Jason.decode!()
        |> Map.get("colleges")
        |> Enum.map(&(&1 |> String.trim() |> String.replace(~r/\s+/, " ")))
        |> MapSet.new()

      rows = Josaa.list_college_program_data(Josaa.latest_year())

      josaa_names =
        rows
        |> Enum.filter(fn
          {"tr", _, data} when length(data) == 7 ->
            match?({"td", _, _}, List.first(data))

          _ ->
            false
        end)
        |> Enum.map(fn {"tr", _, [first_td | _]} ->
          Counselling.Colleges.extract_row_content(first_td)
        end)
        |> Enum.uniq()

      # Normalize like get_college_id does
      alias_map = %{
        "Indian Institute of Information Technology Manipur" =>
          "INDIAN INSTITUTE OF INFORMATION TECHNOLOGY SENAPATI MANIPUR",
        "Institute of Technology, Guru Ghasidas Vishwavidyalaya (A Central University), Bilaspur, (C.G.)" =>
          "School of Studies of Engineering and Technology, Guru Ghasidas Vishwavidyalaya, Bilaspur"
      }

      unresolved =
        Enum.reject(josaa_names, fn name ->
          normalized =
            name
            |> String.trim()
            |> String.replace(~r/\s+/, " ")
            |> String.replace("&", "and")

          canonical = Map.get(alias_map, normalized, normalized)
          MapSet.member?(college_names, canonical) or MapSet.member?(college_names, normalized)
        end)

      # Allow at most 7 unresolved (genuinely new colleges not yet in college-names.json)
      assert length(unresolved) <= 7,
             "#{length(unresolved)} JOSAA colleges unresolved: #{inspect(Enum.take(unresolved, 10))}"
    end

    test "all JOSAA programs can be resolved via get_program_id after normalization" do
      program_data =
        "lib/counselling/data/programs/program-names.json"
        |> File.read!()
        |> Jason.decode!()
        |> Map.get("programs")

      program_keys =
        Enum.map(program_data, fn p ->
          {p["name"] |> String.trim() |> String.replace(~r/\s+/, " "),
           p["duration"],
           p["degree_type"]}
        end)
        |> MapSet.new()

      rows = Josaa.list_college_program_data(Josaa.latest_year())

      program_names =
        rows
        |> Enum.filter(fn
          {"tr", _, data} when length(data) == 7 ->
            match?({"td", _, _}, Enum.at(data, 1))

          _ ->
            false
        end)
        |> Enum.map(fn {"tr", _, data} ->
          Counselling.Colleges.extract_row_content(Enum.at(data, 1))
        end)
        |> Enum.uniq()

      unresolved =
        Enum.reject(program_names, fn raw ->
          normalized =
            raw
            |> String.trim()
            |> String.replace(~r/\s+/, " ")
            |> String.replace("&", "and")

          case Josaa.parse_degree_info(normalized) do
            %{name: name, duration: duration, degree_type: dt} ->
              MapSet.member?(program_keys, {name, duration, dt})

            _ ->
              false
          end
        end)

      assert unresolved == [],
             "#{length(unresolved)} JOSAA programs unresolved: #{inspect(Enum.take(unresolved, 10))}"
    end
  end
end
