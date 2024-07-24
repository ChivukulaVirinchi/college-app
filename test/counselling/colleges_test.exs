defmodule Counselling.CollegesTest do
  use Counselling.DataCase

  alias Counselling.Colleges

  describe "colleges" do
    alias Counselling.Colleges.College

    import Counselling.CollegesFixtures

    @invalid_attrs %{name: nil, location: nil, established_year: nil}

    test "list_colleges/0 returns all colleges" do
      college = college_fixture()
      assert Colleges.list_colleges() == [college]
    end

    test "get_college!/1 returns the college with given id" do
      college = college_fixture()
      assert Colleges.get_college!(college.id) == college
    end

    test "create_college/1 with valid data creates a college" do
      valid_attrs = %{name: "some name", location: "some location", established_year: 42}

      assert {:ok, %College{} = college} = Colleges.create_college(valid_attrs)
      assert college.name == "some name"
      assert college.location == "some location"
      assert college.established_year == 42
    end

    test "create_college/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Colleges.create_college(@invalid_attrs)
    end

    test "update_college/2 with valid data updates the college" do
      college = college_fixture()
      update_attrs = %{name: "some updated name", location: "some updated location", established_year: 43}

      assert {:ok, %College{} = college} = Colleges.update_college(college, update_attrs)
      assert college.name == "some updated name"
      assert college.location == "some updated location"
      assert college.established_year == 43
    end

    test "update_college/2 with invalid data returns error changeset" do
      college = college_fixture()
      assert {:error, %Ecto.Changeset{}} = Colleges.update_college(college, @invalid_attrs)
      assert college == Colleges.get_college!(college.id)
    end

    test "delete_college/1 deletes the college" do
      college = college_fixture()
      assert {:ok, %College{}} = Colleges.delete_college(college)
      assert_raise Ecto.NoResultsError, fn -> Colleges.get_college!(college.id) end
    end

    test "change_college/1 returns a college changeset" do
      college = college_fixture()
      assert %Ecto.Changeset{} = Colleges.change_college(college)
    end
  end
end
