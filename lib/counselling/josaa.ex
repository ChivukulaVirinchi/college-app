defmodule Josaa do
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

  def list_college_program_data(2023) do
    {:ok, document} =
      File.read!("lib/counselling/data/programs/ranks/2023/JoSAA.html")
      |> Floki.parse_document()

    document
    |> Floki.find("table")
    |> Floki.find("#ctl00_ContentPlaceHolder1_GridView1")
    |> hd()
    |> elem(2)
  end

  def list_college_program_data(2024) do
    {:ok, document} =
      File.read!("lib/counselling/data/programs/ranks/2024/JoSAA.html")
      |> Floki.parse_document()

    document
    |> Floki.find("table")
    |> Floki.find("#ctl00_ContentPlaceHolder1_GridView1")
    |> Floki.find("tbody")
    |> hd()
    |> elem(2)
  end
end
