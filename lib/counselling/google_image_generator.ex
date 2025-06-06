defmodule Counselling.GoogleImageClient do
  @moduledoc """
  Client for Google Custom Search API to fetch college images
  """

  @base_url "https://www.googleapis.com/customsearch/v1"

  def search_college_images(college_name) do
    api_key = Application.get_env(:counselling, :google_search_api_key)
    search_engine_id = Application.get_env(:counselling, :google_search_engine_id)

    if is_nil(api_key) or is_nil(search_engine_id) do
      {:error, "Google Search API key or Search Engine ID not configured"}
    else
      search_query = build_search_query(college_name)

      params = %{
        "key" => api_key,
        "cx" => search_engine_id,
        "q" => search_query,
        "searchType" => "image",
        "num" => 3,
        "imgSize" => "large",
        "imgType" => "photo",
        "safe" => "active"
      }

      case Req.get(@base_url, params: params) do
        {:ok, %{status: 200, body: response}} ->
          parse_image_results(response)

        {:ok, %{status: status, body: body}} ->
          {:error, "API request failed with status #{status}: #{inspect(body)}"}

        {:error, error} ->
          {:error, "Request failed: #{inspect(error)}"}
      end
    end
  end

  defp build_search_query(college_name) do
    "#{college_name} campus entrance gate building india"
  end

  defp parse_image_results(response) do
    case response do
      %{"items" => items} when is_list(items) ->
        image_urls =
          items
          |> Enum.take(3)
          |> Enum.map(fn item ->
            %{
              "url" => Map.get(item, "link"),
              "title" => Map.get(item, "title", ""),
              "thumbnail" => get_in(item, ["image", "thumbnailLink"])
            }
          end)
          |> Enum.filter(fn item -> not is_nil(item["url"]) end)

        {:ok, image_urls}

      %{"error" => error} ->
        {:error, "Google API error: #{inspect(error)}"}

      _ ->
        {:error, "No images found or unexpected response format"}
    end
  end
end
