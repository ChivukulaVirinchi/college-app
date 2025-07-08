defmodule Mix.Tasks.GenerateCollegeData do
  use Mix.Task

  @shortdoc "Generate college data using Gemini API"

  def run(_args) do
    Mix.Task.run("app.start")

    IO.puts("Starting college data generation...")

    case Counselling.CollegeDataGenerator.generate_all_college_data() do
      data when is_list(data) ->
        IO.puts("✅ Generated data for #{length(data)} colleges")
        IO.puts("📁 Data saved to: priv/static/generated_college_data.json")

      {:error, reason} ->
        IO.puts("❌ Failed: #{reason}")
    end
  end
end
