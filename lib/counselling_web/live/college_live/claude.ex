defmodule AnthropicApi do
  def call_claude do
    url = "https://api.anthropic.com/v1/messages"

    headers = [
      {"x-api-key", "API key"},
      {"anthropic-version", "2023-06-01"},
      {"content-type", "application/json"}
    ]

    body = %{
      model: "claude-3-5-sonnet-20240620",
      max_tokens: 2048,
      tools: [
        %{
          name: "Colleges",
          description: "Return the College's details in a well-structured JSON.",
          input_schema: %{
            type: "object",
            properties: %{
              name: %{
                type: "string",
                description: "Name of the college"
              },
              established_year: %{
                type: "integer",
                description: "Year that the college was established in"
              },
              location: %{
                type: "string",
                description: "Location of the college. Only city & state will do"
              }
            },
            required: ["name", "established", "location"]
          }
        }
      ],
      tool_choice: %{type: "tool", name: "Colleges"},
      messages: [
        %{
          role: "user",
          content: [
            %{
              type: "text",
              text: "Give me details of the top 5 Colleges participating in JOSAA counselling"
            }
          ]
        }
      ]
    }

    case Req.post(url, headers: headers, json: body) do
      {:ok, response} ->
        response |> dbg()

      {:error, error} ->
        IO.puts("Error: #{inspect(error)}")
    end
  end
end
