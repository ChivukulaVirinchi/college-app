defmodule Counselling.CollegeDataGenerator do
  @moduledoc """
  Simple batch processing for college data generation.
  """

  require Logger
  alias Counselling.Repo
  alias Counselling.Colleges.College
  import Ecto.Query

  @batch_size 5
  @delay_between_batches 2_000
  @delay_between_requests 500

  def generate_all_college_data do
    colleges = fetch_college_names()
    process_in_batches(colleges)
  end

  def generate_college_data(college_name, college_class \\ "GFTI") do
    case Counselling.GeminiClient.generate_college_data(college_name, college_class) do
      {:ok, data} ->
        enhanced_data = Map.merge(data, %{
          "name" => college_name,
          "class" => college_class
        })
        {:ok, enhanced_data}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  def append_to_file(college_data_list) do
    file_path = "priv/static/generated_college_data.json"
    
    existing_data = case File.read(file_path) do
      {:ok, content} -> 
        case Jason.decode(content) do
          {:ok, data} when is_list(data) -> data
          _ -> []
        end
      _ -> []
    end
    
    updated_data = existing_data ++ college_data_list
    json_content = Jason.encode!(updated_data, pretty: true)
    File.write!(file_path, json_content)
    {:ok, updated_data}
  end

  defp fetch_college_names do
    Repo.all(from c in College, select: %{name: c.name, class: c.class})
  end

  defp process_in_batches(colleges) do
    File.mkdir_p!("priv/static")
    
    colleges
    |> Enum.chunk_every(@batch_size)
    |> Enum.reduce([], fn batch, acc ->
      batch_results = process_batch(batch)
      append_to_file(batch_results)
      Process.sleep(@delay_between_batches)
      acc ++ batch_results
    end)
  end

  defp process_batch(batch) do
    Enum.map(batch, fn college ->
      case generate_college_data(college.name, Atom.to_string(college.class)) do
        {:ok, data} ->
          Logger.info("Generated data for #{college.name}")
          Process.sleep(@delay_between_requests)
          data
        {:error, reason} ->
          Logger.error("Failed for #{college.name}: #{reason}")
          Process.sleep(@delay_between_requests)
          nil
      end
    end)
    |> Enum.filter(&(!is_nil(&1)))
  end
end