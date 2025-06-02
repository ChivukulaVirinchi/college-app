defmodule Counselling.GeminiClient do
  @moduledoc """
  Client for Google Gemini API to generate college data
  """

  @base_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent"

  def generate_college_data(college_name, college_class) do
    prompt = build_college_prompt(college_name, college_class)

    case call_gemini(prompt) do
      {:ok, response} -> parse_college_response(response)
      {:error, error} -> {:error, error}
    end
  end

  def generate_multiple_colleges(college_list) do
    prompt = build_multiple_colleges_prompt(college_list)

    case call_gemini(prompt) do
      {:ok, response} -> parse_multiple_colleges_response(response)
      {:error, error} -> {:error, error}
    end
  end

  defp call_gemini(prompt) do
    api_key = Application.get_env(:counselling, :gemini_api_key)

    if is_nil(api_key) do
      {:error, "Gemini API key not configured"}
    else
      body = %{
        "contents" => [
          %{
            "parts" => [
              %{
                "text" => prompt
              }
            ]
          }
        ]
      }

      case Req.post("#{@base_url}?key=#{api_key}",
             headers: [{"Content-Type", "application/json"}],
             json: body
           ) do
        {:ok, %{status: 200, body: response}} ->
          {:ok, response}

        {:ok, %{status: status, body: body}} ->
          {:error, "API request failed with status #{status}: #{inspect(body)}"}

        {:error, error} ->
          {:error, "Request failed: #{inspect(error)}"}
      end
    end
  end

  defp build_college_prompt(college_name, college_class) do
    """
    Generate accurate JSON data for this Indian engineering college participating in JOSAA counselling:

    College: #{college_name}
    Type: #{college_class}

    Provide ONLY valid JSON in this exact format (no extra text). This data will be shown to students who are thinking of joining said colleges.
    Make it useful for them. Don't talk about programs offered by that college. Don't state obvious things.

    {
      "location": "City, State",
      "established_year": year_as_integer_or_null,
      "campus_area_acres": estimated_acres_or_null,
      "description": "2-3 sentence description about college. Keep it factual",
      "official_website": "website_url_or_null"
    }

    Important guidelines:
    - Use null for uncertain data, never guess
    - Be accurate with establishment years and locations
    - Keep descriptions factual and focused on academics
    - Only include verifiable information
    - Return ONLY the JSON object, no explanations
    """
  end

  defp build_multiple_colleges_prompt(college_list) do
    college_names =
      Enum.map(college_list, fn %{name: name, class: class} ->
        "#{name} (#{class})"
      end)
      |> Enum.join(", ")

    """
    Generate accurate JSON data for these Indian engineering colleges participating in JOSAA counselling:

    Colleges: #{college_names}

    Provide ONLY valid JSON in this exact format (no extra text). This data will be shown to students who are thinking of joining said colleges.
    Make it useful for them. Don't talk about programs offered by that college.
    {
      "colleges": [
        {
          "name": "exact college name",
          "location": "City, State",
          "established_year": year_as_integer_or_null,
          "campus_area_acres": estimated_acres_or_null,
          "description": "2-3 sentence description about college. Keep it factual",
          "official_website": "website_url_or_null",

        }
      ]
    }

    Important guidelines:
    - Use null for uncertain data, never guess
    - Be accurate with establishment years and locations
    - Keep descriptions factual and focused on academics
    - Maintain exact college names as provided
    - Return ONLY the JSON object, no explanations
    """
  end

  defp parse_college_response(response) do
    case extract_text_from_response(response) do
      {:ok, text} ->
        case Jason.decode(text) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, "Invalid JSON response from Gemini"}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_multiple_colleges_response(response) do
    case extract_text_from_response(response) do
      {:ok, text} ->
        case Jason.decode(text) do
          {:ok, %{"colleges" => colleges}} -> {:ok, colleges}
          {:ok, _} -> {:error, "Response missing 'colleges' field"}
          {:error, _} -> {:error, "Invalid JSON response from Gemini"}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp extract_text_from_response(response) do
    case response do
      %{"candidates" => [%{"content" => %{"parts" => [%{"text" => text} | _]}} | _]} ->
        cleaned_text =
          text
          |> String.trim()
          |> String.replace(~r/^```json\s*/, "")
          |> String.replace(~r/\s*```$/, "")

        {:ok, cleaned_text}

      _ ->
        {:error, "Unexpected response format from Gemini API"}
    end
  end
end
