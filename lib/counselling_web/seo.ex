defmodule CounsellingWeb.SEO do
  @moduledoc false

  @site_name "JOSAA Counselling Helper"
  @default_description "Find engineering colleges and programs based on your JEE rank, JoSAA cutoffs, and NIRF rankings."
  @default_image_path "/images/og-default.jpg"

  def site_name, do: @site_name
  def default_description, do: @default_description

  def default_social_image(base_url) do
    absolute_url(base_url, @default_image_path)
  end

  def absolute_url(base_url, nil), do: default_social_image(base_url)
  def absolute_url(_base_url, "http" <> _ = url), do: url

  def absolute_url(base_url, path) when is_binary(path) do
    base_url
    |> URI.merge("/" <> String.trim_leading(path, "/"))
    |> URI.to_string()
  end

  def website_json_ld(base_url) do
    %{
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => @site_name,
      "url" => base_url,
      "description" => @default_description,
      "potentialAction" => %{
        "@type" => "SearchAction",
        "target" => "#{base_url}/colleges?search={search_term_string}",
        "query-input" => "required name=search_term_string"
      }
    }
  end

  def organization_json_ld(base_url) do
    %{
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => @site_name,
      "url" => base_url,
      "logo" => default_social_image(base_url)
    }
  end

  def web_page_json_ld(title, description, canonical_url) do
    %{
      "@context" => "https://schema.org",
      "@type" => "WebPage",
      "name" => title,
      "description" => description,
      "url" => canonical_url,
      "isPartOf" => %{"@type" => "WebSite", "name" => @site_name}
    }
  end

  def breadcrumb_json_ld(items) do
    %{
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" =>
        items
        |> Enum.with_index(1)
        |> Enum.map(fn {{name, url}, position} ->
          %{
            "@type" => "ListItem",
            "position" => position,
            "name" => name,
            "item" => url
          }
        end)
    }
  end

  def college_json_ld(college, canonical_url, image_url) do
    %{
      "@context" => "https://schema.org",
      "@type" => "CollegeOrUniversity",
      "name" => college.name,
      "url" => canonical_url,
      "description" => college.description,
      "image" => image_url,
      "foundingDate" => to_string(college.established_year),
      "address" => %{
        "@type" => "PostalAddress",
        "addressLocality" => college.location,
        "addressCountry" => "IN"
      },
      "sameAs" => Enum.reject([college.website], &is_nil/1)
    }
  end

  def course_json_ld(program, canonical_url, provider_name \\ @site_name) do
    %{
      "@context" => "https://schema.org",
      "@type" => "Course",
      "name" => program.name,
      "url" => canonical_url,
      "description" => "#{program.name} #{program.degree_type} program with JoSAA cutoff data.",
      "provider" => %{
        "@type" => "Organization",
        "name" => provider_name
      },
      "timeRequired" => "P#{program.duration}Y"
    }
  end

  def faq_json_ld(questions) do
    %{
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" =>
        Enum.map(questions, fn {question, answer} ->
          %{
            "@type" => "Question",
            "name" => question,
            "acceptedAnswer" => %{
              "@type" => "Answer",
              "text" => answer
            }
          }
        end)
    }
  end
end
