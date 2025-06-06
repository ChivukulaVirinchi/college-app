defmodule Counselling.ImageDownloader do
  @moduledoc """
  Downloads college images and updates the college data JSON
  """

  require Logger

  @images_dir "priv/static/images/colleges"
  @delay_between_requests 1_500

  def download_all_college_images do
    File.mkdir_p!(@images_dir)

    case load_college_data() do
      {:ok, college_data} ->
        college_names = Map.keys(college_data)
        Logger.info("Found #{length(college_names)} colleges to process for images")

        process_colleges_for_images(college_names, college_data)

      {:error, reason} ->
        Logger.error("Failed to load college data: #{reason}")
        {:error, reason}
    end
  end

  def download_single_college_image(college_name) do
    File.mkdir_p!(@images_dir)

    case load_college_data() do
      {:ok, college_data} ->
        if Map.has_key?(college_data, college_name) do
          process_single_college_image(college_name, college_data)
        else
          {:error, "College not found in data: #{college_name}"}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def download_missing_images do
    # File.mkdir_p!(@images_dir)

    case load_college_data() do
      {:ok, college_data} ->
        colleges_without_images =
          college_data
          |> Enum.filter(fn {_name, data} ->
            image_path = Map.get(data, "image_path")
            is_nil(image_path) or image_path == ""
          end)
          |> Enum.map(fn {name, _data} -> name end)

        Logger.info("Found #{length(colleges_without_images)} colleges without images")

        if length(colleges_without_images) > 0 do
          Logger.info("Starting download for missing images...")
          process_colleges_for_images(colleges_without_images, college_data)
          Logger.info("Completed downloading missing images")
        else
          Logger.info("All colleges already have images!")
        end

      {:error, reason} ->
        Logger.error("Failed to load college data: #{reason}")
        {:error, reason}
    end
  end

  defp load_college_data do
    file_path = "priv/static/generated_college_data.json"

    case File.read(file_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, data} when is_map(data) -> {:ok, data}
          {:ok, _} -> {:error, "Invalid JSON structure"}
          {:error, _} -> {:error, "Invalid JSON format"}
        end

      {:error, _} ->
        {:error, "College data file not found"}
    end
  end

  defp process_colleges_for_images(college_names, college_data) do
    total_colleges = length(college_names)

    college_names
    |> Enum.with_index(1)
    |> Enum.reduce(college_data, fn {college_name, index}, acc_data ->
      Logger.info("Processing images for #{college_name} (#{index}/#{total_colleges})")

      case process_single_college_image(college_name, acc_data) do
        {:ok, updated_data} ->
          if index < total_colleges do
            Logger.info("Waiting #{@delay_between_requests}ms before next request...")
            Process.sleep(@delay_between_requests)
          end

          updated_data

        {:error, reason} ->
          Logger.error("Failed to process images for #{college_name}: #{reason}")
          Process.sleep(@delay_between_requests)
          acc_data
      end
    end)
  end

  defp process_single_college_image(college_name, college_data) do
    case Counselling.GoogleImageClient.search_college_images(college_name) do
      {:ok, image_results} ->
        case download_best_image(college_name, image_results) do
          {:ok, local_path} ->
            updated_data = update_college_with_image(college_data, college_name, local_path)
            save_updated_data(updated_data)
            Logger.info("✓ Downloaded image for #{college_name}: #{local_path}")
            {:ok, updated_data}

          {:error, reason} ->
            Logger.error("✗ Failed to download image for #{college_name}: #{reason}")
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("✗ Failed to search images for #{college_name}: #{reason}")
        {:error, reason}
    end
  end

  defp download_best_image(college_name, image_results) do
    sanitized_name = sanitize_filename(college_name)

    image_results
    |> Enum.with_index()
    |> Enum.reduce_while({:error, "No images could be downloaded"}, fn {image, index}, _acc ->
      file_extension = get_file_extension(image["url"])
      filename = "#{sanitized_name}_#{index + 1}#{file_extension}"
      local_path = Path.join(@images_dir, filename)

      case download_image(image["url"], local_path) do
        :ok ->
          relative_path = Path.join("images/colleges", filename)
          {:halt, {:ok, relative_path}}

        {:error, reason} ->
          Logger.warn("Failed to download image #{index + 1} for #{college_name}: #{reason}")
          {:cont, {:error, "No images could be downloaded"}}
      end
    end)
  end

  defp download_image(url, local_path) do
    case System.cmd(
           "wget",
           [
             url,
             "-O",
             local_path,
             "--timeout=30",
             "--tries=2",
             "--user-agent=Mozilla/5.0 (compatible; CollegeImageBot/1.0)"
           ],
           stderr_to_stdout: true
         ) do
      {_output, 0} ->
        # Verify file was created and has content
        case File.stat(local_path) do
          {:ok, %{size: size}} when size > 1000 ->
            :ok

          {:ok, %{size: size}} ->
            File.rm(local_path)
            {:error, "Downloaded file too small: #{size} bytes"}

          {:error, reason} ->
            {:error, "File verification failed: #{reason}"}
        end

      {output, exit_code} ->
        {:error, "wget failed (exit #{exit_code}): #{String.trim(output)}"}
    end
  end

  defp sanitize_filename(college_name) do
    college_name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "_")
    |> String.trim("_")
  end

  defp get_file_extension(url) do
    case Path.extname(URI.parse(url).path || "") do
      "" -> ".jpg"
      ext when ext in [".jpg", ".jpeg", ".png", ".gif", ".webp"] -> ext
      _ -> ".jpg"
    end
  end

  defp update_college_with_image(college_data, college_name, image_path) do
    current_college_data = Map.get(college_data, college_name, %{})
    updated_college_data = Map.put(current_college_data, "image_path", image_path)
    Map.put(college_data, college_name, updated_college_data)
  end

  defp save_updated_data(college_data) do
    file_path = "priv/static/generated_college_data.json"
    json_content = Jason.encode!(college_data, pretty: true)
    File.write!(file_path, json_content)
  end
end
