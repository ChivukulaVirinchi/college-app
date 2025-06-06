defmodule Counselling.CollegeDataGenerator do
  @moduledoc """
  Generate college data using Claude Haiku with tool calling
  JSON structure: {"college_name": {data}}
  """

  require Logger
  alias Counselling.Repo
  alias Counselling.Colleges.College
  import Ecto.Query

  @batch_size 3
  @delay_between_batches 3_000
  @delay_between_requests 1_000

  def generate_all_college_data do
    colleges = fetch_college_names()
    Logger.info("Found #{length(colleges)} colleges to process")

    File.mkdir_p!("priv/static")
    initialize_json_file()

    process_in_batches(colleges)
  end

  def generate_single_college(college_name) do
    case Counselling.ClaudeClient.generate_college_data(college_name) do
      {:ok, data} ->
        # Write single college to file immediately
        append_single_to_file(college_name, data)
        {:ok, data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_college_names do
    Repo.all(from c in College, select: c.name)
  end

  defp initialize_json_file do
    file_path = "priv/static/generated_college_data.json"
    File.write!(file_path, "{}")
  end

  defp process_in_batches(colleges) do
    total_batches = ceil(length(colleges) / @batch_size)

    colleges
    |> Enum.chunk_every(@batch_size)
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn {batch, batch_num}, acc ->
      Logger.info("Processing batch #{batch_num}/#{total_batches}")

      batch_results = process_batch(batch)
      append_batch_to_file(batch_results)

      if batch_num < total_batches do
        Logger.info("Waiting #{@delay_between_batches}ms before next batch...")
        Process.sleep(@delay_between_batches)
      end

      Map.merge(acc, batch_results)
    end)
  end

  defp process_batch(batch) do
    Enum.reduce(batch, %{}, fn college_name, acc ->
      case generate_college_data_only(college_name) do
        {:ok, data} ->
          Logger.info("✓ Generated data for #{college_name}")
          Process.sleep(@delay_between_requests)
          Map.put(acc, college_name, data)

        {:error, reason} ->
          Logger.error("✗ Failed for #{college_name}: #{reason}")
          Process.sleep(@delay_between_requests)
          acc
      end
    end)
  end

  defp generate_college_data_only(college_name) do
    Counselling.ClaudeClient.generate_college_data(college_name)
  end

  defp append_single_to_file(college_name, college_data) do
    file_path = "priv/static/generated_college_data.json"

    existing_data =
      case File.read(file_path) do
        {:ok, content} ->
          case Jason.decode(content) do
            {:ok, data} when is_map(data) -> data
            _ -> %{}
          end

        _ ->
          %{}
      end

    updated_data = Map.put(existing_data, college_name, college_data)
    json_content = Jason.encode!(updated_data, pretty: true)
    File.write!(file_path, json_content)

    Logger.info("Added #{college_name} to file. Total colleges: #{map_size(updated_data)}")
    {:ok, updated_data}
  end

  defp append_batch_to_file(batch_data) when map_size(batch_data) > 0 do
    file_path = "priv/static/generated_college_data.json"

    existing_data =
      case File.read(file_path) do
        {:ok, content} ->
          case Jason.decode(content) do
            {:ok, data} when is_map(data) -> data
            _ -> %{}
          end

        _ ->
          %{}
      end

    updated_data = Map.merge(existing_data, batch_data)
    json_content = Jason.encode!(updated_data, pretty: true)
    File.write!(file_path, json_content)

    Logger.info(
      "Added #{map_size(batch_data)} colleges to file. Total: #{map_size(updated_data)}"
    )

    {:ok, updated_data}
  end

  defp append_batch_to_file(_), do: {:ok, %{}}
end
