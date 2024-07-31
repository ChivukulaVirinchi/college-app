defmodule Populate do
  def create_colleges do
    colleges = [
      %{
        name: "IIT Delhi",
        location: "New Delhi",
        established_year: 1961,
        nirfrank: 2,
        class: :IIT,
        link_to_website: "http://www.iitd.ac.in",
        campus_area: 320
      },
      %{
        name: "NIT Trichy",
        location: "Tiruchirappalli",
        established_year: 1964,
        nirfrank: 9,
        class: :NIT,
        link_to_website: "https://www.nitt.edu",
        campus_area: 800
      }
      # Add more colleges as needed
    ]

    Enum.each(colleges, fn college ->
      Counselling.Colleges.create_college(college)
    end)
  end

  def create_branches do
    branches = [
      %{name: "Computer Science and Engineering"},
      %{name: "Electrical Engineering"},
      %{name: "Mechanical Engineering"}
      # Add more branches as needed
    ]

    Enum.each(branches, fn branch ->
      Counselling.Branches.create_branch(branch)
    end)
  end

  def create_college_branch_associations do
    # Get all colleges and branches
    colleges = Counselling.Colleges.list_colleges()
    branches = Counselling.Branches.list_branches()

    # Create associations (you can customize this based on your requirements)
    Enum.each(colleges, fn college ->
      # Randomly select some branches for each college
      selected_branches = Enum.take_random(branches, :rand.uniform(length(branches)))

      Enum.each(selected_branches, fn branch ->
        Counselling.Colleges.create_college_branch(%{college_id: college.id, branch_id: branch.id})
      end)
    end)
  end

  def populate_database do
    create_colleges()
    create_branches()
    create_college_branch_associations()
  end
end

Populate.populate_database() |> dbg()
