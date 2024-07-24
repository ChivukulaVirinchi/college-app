defmodule CounsellingWeb.CollegeLiveTest do
  use CounsellingWeb.ConnCase

  import Phoenix.LiveViewTest
  import Counselling.CollegesFixtures

  @create_attrs %{name: "some name", location: "some location", established_year: 42}
  @update_attrs %{name: "some updated name", location: "some updated location", established_year: 43}
  @invalid_attrs %{name: nil, location: nil, established_year: nil}

  defp create_college(_) do
    college = college_fixture()
    %{college: college}
  end

  describe "Index" do
    setup [:create_college]

    test "lists all colleges", %{conn: conn, college: college} do
      {:ok, _index_live, html} = live(conn, ~p"/colleges")

      assert html =~ "Listing Colleges"
      assert html =~ college.name
    end

    test "saves new college", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/colleges")

      assert index_live |> element("a", "New College") |> render_click() =~
               "New College"

      assert_patch(index_live, ~p"/colleges/new")

      assert index_live
             |> form("#college-form", college: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#college-form", college: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/colleges")

      html = render(index_live)
      assert html =~ "College created successfully"
      assert html =~ "some name"
    end

    test "updates college in listing", %{conn: conn, college: college} do
      {:ok, index_live, _html} = live(conn, ~p"/colleges")

      assert index_live |> element("#colleges-#{college.id} a", "Edit") |> render_click() =~
               "Edit College"

      assert_patch(index_live, ~p"/colleges/#{college}/edit")

      assert index_live
             |> form("#college-form", college: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#college-form", college: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/colleges")

      html = render(index_live)
      assert html =~ "College updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes college in listing", %{conn: conn, college: college} do
      {:ok, index_live, _html} = live(conn, ~p"/colleges")

      assert index_live |> element("#colleges-#{college.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#colleges-#{college.id}")
    end
  end

  describe "Show" do
    setup [:create_college]

    test "displays college", %{conn: conn, college: college} do
      {:ok, _show_live, html} = live(conn, ~p"/colleges/#{college}")

      assert html =~ "Show College"
      assert html =~ college.name
    end

    test "updates college within modal", %{conn: conn, college: college} do
      {:ok, show_live, _html} = live(conn, ~p"/colleges/#{college}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit College"

      assert_patch(show_live, ~p"/colleges/#{college}/show/edit")

      assert show_live
             |> form("#college-form", college: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#college-form", college: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/colleges/#{college}")

      html = render(show_live)
      assert html =~ "College updated successfully"
      assert html =~ "some updated name"
    end
  end
end
