defmodule Counselling.CollegeBannerGenerator do
  @moduledoc """
  Generates SVG banners for colleges that can be converted to images
  """

  @images_dir "priv/static/images/colleges"
  @banner_width 800
  @banner_height 300

  def generate_all_banners do
    File.mkdir_p!(@images_dir)

    case load_college_data() do
      {:ok, college_data} ->
        college_data
        |> Enum.each(fn {college_name, data} ->
          generate_banner_for_college(college_name, data)
        end)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def generate_banner_for_college(college_name, college_data) do
    college_class = String.to_atom(Map.get(college_data, "class", "OTHER"))
    location = Map.get(college_data, "location", "")
    established_year = Map.get(college_data, "established_year", "")

    svg_content =
      create_svg_banner(%{
        name: college_name,
        class: college_class,
        location: location,
        established_year: established_year
      })

    filename = sanitize_filename(college_name) <> ".svg"
    file_path = Path.join(@images_dir, filename)

    case File.write(file_path, svg_content) do
      :ok ->
        relative_path = Path.join("images/colleges", filename)
        update_college_with_image_path(college_name, relative_path)
        {:ok, relative_path}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_svg_banner(%{name: name, class: class, location: location, established_year: year}) do
    {bg_gradient, text_color, accent_color} = get_color_scheme(class)

    """
    <svg width="#{@banner_width}" height="#{@banner_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{bg_gradient}
        <pattern id="dots" patternUnits="userSpaceOnUse" width="20" height="20">
          <circle cx="10" cy="10" r="1" fill="white" opacity="0.1"/>
        </pattern>
      </defs>

      <!-- Background -->
      <rect width="100%" height="100%" fill="url(#gradient)"/>
      <rect width="100%" height="100%" fill="url(#dots)"/>

      <!-- Geometric accent -->
      <polygon points="0,0 150,0 100,#{@banner_height}" fill="#{accent_color}" opacity="0.1"/>

      <!-- Institution badge -->
      <rect x="40" y="40" width="80" height="30" rx="15" fill="white" opacity="0.9"/>
      <text x="80" y="60" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" font-weight="bold" fill="#{accent_color}">#{class}</text>

      <!-- College name -->
      <text x="40" y="120" font-family="Georgia, serif" font-size="28" font-weight="bold" fill="#{text_color}">
        #{truncate_text(name, 25)}
      </text>

      <!-- Location -->
      <text x="40" y="150" font-family="Arial, sans-serif" font-size="16" fill="#{text_color}" opacity="0.8">
        📍 #{location}
      </text>

      <!-- Established year -->
      <text x="40" y="180" font-family="Arial, sans-serif" font-size="14" fill="#{text_color}" opacity="0.7">
        Est. #{year}
      </text>

      <!-- Decorative element -->
      <circle cx="700" cy="80" r="60" fill="white" opacity="0.05"/>
      <circle cx="720" cy="200" r="40" fill="white" opacity="0.05"/>
    </svg>
    """
  end

  defp get_color_scheme(:IIT) do
    gradient = """
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#8b5cf6;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#7c3aed;stop-opacity:1" />
    </linearGradient>
    """

    {gradient, "white", "#8b5cf6"}
  end

  defp get_color_scheme(:NIT) do
    gradient = """
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2563eb;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1d4ed8;stop-opacity:1" />
    </linearGradient>
    """

    {gradient, "white", "#2563eb"}
  end

  defp get_color_scheme(:IIIT) do
    gradient = """
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#059669;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#047857;stop-opacity:1" />
    </linearGradient>
    """

    {gradient, "white", "#059669"}
  end

  defp get_color_scheme(:GFTI) do
    gradient = """
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#ea580c;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#dc2626;stop-opacity:1" />
    </linearGradient>
    """

    {gradient, "white", "#ea580c"}
  end

  defp get_color_scheme(_) do
    gradient = """
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#6b7280;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4b5563;stop-opacity:1" />
    </linearGradient>
    """

    {gradient, "white", "#6b7280"}
  end

  defp truncate_text(text, max_length) do
    if String.length(text) > max_length do
      String.slice(text, 0, max_length - 3) <> "..."
    else
      text
    end
  end

  defp sanitize_filename(college_name) do
    college_name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "_")
    |> String.trim("_")
  end

  defp load_college_data do
    # Use your existing load_college_data function
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

  defp update_college_with_image_path(college_name, image_path) do
    case load_college_data() do
      {:ok, college_data} ->
        current_college_data = Map.get(college_data, college_name, %{})
        updated_college_data = Map.put(current_college_data, "image_path", image_path)
        updated_data = Map.put(college_data, college_name, updated_college_data)
        save_updated_data(updated_data)

      {:error, _} ->
        :error
    end
  end

  defp save_updated_data(college_data) do
    file_path = "priv/static/generated_college_data.json"
    json_content = Jason.encode!(college_data, pretty: true)
    File.write!(file_path, json_content)
  end
end
