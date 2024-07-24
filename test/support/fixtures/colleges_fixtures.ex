defmodule Counselling.CollegesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Counselling.Colleges` context.
  """

  @doc """
  Generate a college.
  """
  def college_fixture(attrs \\ %{}) do
    {:ok, college} =
      attrs
      |> Enum.into(%{
        established_year: 42,
        location: "some location",
        name: "some name"
      })
      |> Counselling.Colleges.create_college()

    college
  end
end
