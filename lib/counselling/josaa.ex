defmodule Josaa do
  @latest_year 2025

  def latest_year, do: @latest_year

  def list_colleges() do
    {:ok, document} =
      File.read!("lib/counselling/data/JoSAA.html") |> Floki.parse_document()

    document
    |> Floki.find("select#college")
    |> Floki.find("option")
    |> Enum.drop(2)
    |> Enum.map(fn {_, _, [name]} -> name |> String.trim() end)
    |> write_to_json("colleges", "lib/counselling/data/colleges/college-names.json")
  end

  def list_programs() do
    {:ok, document} =
      File.read!("lib/counselling/data/JoSAA.html") |> Floki.parse_document()

    document
    |> Floki.find("select#sleep")
    |> Floki.find("option")
    |> Enum.drop(2)
    |> Enum.map(fn {_, _, [name]} -> parse_degree_info(name) end)
    |> Enum.uniq()
    |> write_to_json("programs", "lib/counselling/data/programs/program-names.json")
  end

  defp write_to_json(content, key, output_path) do
    json = Jason.encode!(%{key => content}, pretty: true)

    case File.write(output_path, json) do
      :ok ->
        IO.puts("Successfully wrote #{length(content)} #{key} to #{output_path}")
        {:ok, output_path}

      {:error, reason} ->
        IO.puts("Failed to write JSON file: #{reason}")
        {:error, reason}
    end
  end

  def parse_degree_info(degree_string) do
    regex = ~r/^(?<name>.+?)\s*\((?<duration>\d+)\s*Years,\s*(?<program>.+?)\)$/

    case Regex.named_captures(regex, degree_string) do
      %{"name" => name, "duration" => duration, "program" => program} ->
        %{
          name: String.trim(name),
          duration: String.to_integer(duration),
          degree_type: program
        }

      _ ->
        {:error, "Invalid format"}
    end
  end

  def list_college_program_data(year) do
    file =
      case year do
        2025 -> "lib/counselling/data/programs/ranks/2025/JOSAA.html"
        y -> "lib/counselling/data/programs/ranks/#{y}/JoSAA.html"
      end

    {:ok, document} = File.read!(file) |> Floki.parse_document()

    document
    |> Floki.find("table")
    |> Floki.find("#ctl00_ContentPlaceHolder1_GridView1")
    |> hd()
    |> elem(2)
  end

  def seat_type_atom("OPEN"), do: :open
  def seat_type_atom("OBC-NCL"), do: :obc_ncl
  def seat_type_atom("SC"), do: :sc
  def seat_type_atom("ST"), do: :st
  def seat_type_atom("EWS"), do: :ews
  def seat_type_atom("OPEN (PwD)"), do: :open_pwd
  def seat_type_atom("OBC-NCL (PwD)"), do: :obc_ncl_pwd
  def seat_type_atom("SC (PwD)"), do: :sc_pwd
  def seat_type_atom("ST (PwD)"), do: :st_pwd
  def seat_type_atom("EWS (PwD)"), do: :ews_pwd
end
