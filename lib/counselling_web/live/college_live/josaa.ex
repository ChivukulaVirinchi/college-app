defmodule Josaa do
  import Ecto.Query
  alias Counselling.Programs.Program
  alias Counselling.Repo

  def colleges_list() do
    {:ok, document} =
      File.read!("lib/counselling_web/live/JoSAA.html") |> Floki.parse_document()

    # colleges =
    document
    |> Floki.find("table")
    |> Floki.find("#ctl00_ContentPlaceHolder1_GridView1")
    |> Floki.find("tbody")
    # Get the list of option elements
    |> Floki.find("tr")

    ##################################################################
    # |> hd()
    # |> elem(2)
    # |> Enum.filter(fn
    #   {"option", _, [text]} -> text != "--Select--" and text != "ALL"
    #   _ -> false
    # end)
    # |> Enum.map(fn {"option", _, [text]} ->
    # %{name: text}
    #   text
    # end)
    #######################################################################
    # |> dbg()

    # json = Jason.encode!(%{colleges: colleges}, pretty: true)
    # File.write("lib/counselling_web/live/college-names.json", json)
  end

  def parse_degree_info(degree_string) do
    regex = ~r/^(?<name>.+?)\s*\((?<duration>\d+)\s*Years,\s*(?<program>.+?)\)$/

    case Regex.named_captures(regex, degree_string) do
      %{"name" => name, "duration" => duration, "program" => program} ->
        %{
          name: name,
          duration: String.to_integer(duration),
          degree_type: program
        }

      _ ->
        {:error, "Invalid format"}
    end
  end

  def count_duplicate_program_names do
    query =
      from p in Program,
        group_by: p.name,
        having: count(p.name) > 1,
        select: %{name: p.name, count: count(p.name)}

    Repo.all(query)
  end
end

# Example usage:
# duplicate_count = ProgramQueries.count_duplicate_program_names()
# IO.puts("Number of duplicate program names: #{duplicate_count}")
