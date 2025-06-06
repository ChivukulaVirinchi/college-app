defmodule Counselling.ClaudeClient do
  @moduledoc """
  Client for Claude Haiku API to generate college data with tool calling
  """

  @base_url "https://api.anthropic.com/v1/messages"
  @model "claude-3-5-haiku-20241022"

  def generate_college_data(college_name) do
    case call_claude_with_tools(college_name) do
      {:ok, response} -> parse_claude_response(response)
      {:error, error} -> {:error, error}
    end
  end

  defp call_claude_with_tools(college_name) do
    api_key = Application.get_env(:counselling, :claude_api_key)

    if is_nil(api_key) do
      {:error, "Claude API key not configured"}
    else
      body = %{
        "model" => @model,
        "max_tokens" => 1000,
        "tools" => [college_data_tool()],
        "tool_choice" => %{"type" => "tool", "name" => "generate_college_info"},
        "messages" => [
          %{
            "role" => "user",
            "content" => build_prompt(college_name)
          }
        ]
      }

      case Req.post(@base_url,
             headers: [
               {"Content-Type", "application/json"},
               {"x-api-key", api_key},
               {"anthropic-version", "2023-06-01"}
             ],
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

  defp college_data_tool do
    %{
      "name" => "generate_college_info",
      "description" => "Generate structured college information for JOSAA counselling",
      "input_schema" => %{
        "type" => "object",
        "properties" => %{
          "location" => %{
            "type" => "string",
            "description" => "City, State format"
          },
          "established_year" => %{
            "type" => ["integer", "null"],
            "description" => "Year college was established"
          },
          "campus_area_acres" => %{
            "type" => ["number", "null"],
            "description" => "Campus area in acres"
          },
          "description" => %{
            "type" => "string",
            "description" => "2-3 sentence factual description"
          },
          "official_website" => %{
            "type" => ["string", "null"],
            "description" => "Official website URL"
          }
        },
        "required" => ["location", "description"]
      }
    }
  end

  defp build_prompt(college_name) do
    """
    Generate accurate information for this Indian engineering college participating in JOSAA counselling:

    College: #{college_name}

    This data will help JOSAA counselling students make informed decisions.
    Provide factual information only. Use null for uncertain data.
    Keep the description focused on what makes this institution notable.
    """
  end

  defp parse_claude_response(response) do
    case response do
      %{"content" => [%{"type" => "tool_use", "input" => tool_input} | _]} ->
        {:ok, tool_input}

      %{"content" => content} when is_list(content) ->
        # Find tool use in content
        tool_use =
          Enum.find(content, fn item ->
            Map.get(item, "type") == "tool_use"
          end)

        case tool_use do
          %{"input" => tool_input} -> {:ok, tool_input}
          _ -> {:error, "No tool use found in response"}
        end

      _ ->
        {:error, "Unexpected response format from Claude API"}
    end
  end
end
