# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Counselling.Repo.insert!(%Counselling.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# In seeds.exs
alias Counselling.Repo
alias Counselling.Colleges.College
alias Counselling.Branches.Branch
alias Counselling.CollegeBranches.CollegeBranch

# Create branches
branches = [
  %{name: "Computer Science and Engineering"},
  %{name: "Electrical Engineering"},
  %{name: "Mechanical Engineering"},
  %{name: "Civil Engineering"},
  %{name: "Chemical Engineering"},
  %{name: "Electronics and Communication Engineering"}
]

created_branches =
  Enum.map(branches, fn branch ->
    {:ok, created_branch} = Repo.insert(%Branch{name: branch.name})
    created_branch
  end)

# Create colleges with branches
colleges = [
  %{
    name: "Indian Institute of Technology, Bombay",
    location: "Mumbai",
    established_year: 1958,
    nirfrank: 1,
    class: :IIT
  },
  %{
    name: "Indian Institute of Technology, Delhi",
    location: "New Delhi",
    established_year: 1961,
    nirfrank: 2,
    class: :IIT
  },
  %{
    name: "Indian Institute of Technology, Madras",
    location: "Chennai",
    established_year: 1959,
    nirfrank: 3,
    class: :IIT
  },
  %{
    name: "National Institute of Technology, Tiruchirappalli",
    location: "Tiruchirappalli",
    established_year: 1964,
    nirfrank: 4,
    class: :NIT
  },
  %{
    name: "Indian Institute of Technology, Kanpur",
    location: "Kanpur",
    established_year: 1959,
    nirfrank: 5,
    class: :IIT
  },
  %{
    name: "Indian Institute of Technology, Kharagpur",
    location: "Kharagpur",
    established_year: 1951,
    nirfrank: 6,
    class: :IIT
  },
  %{
    name: "Indian Institute of Technology, Roorkee",
    location: "Roorkee",
    established_year: 1847,
    nirfrank: 7,
    class: :IIT
  },
  %{
    name: "Indian Institute of Technology, Guwahati",
    location: "Guwahati",
    established_year: 1994,
    nirfrank: 8,
    class: :IIT
  },
  %{
    name: "National Institute of Technology, Rourkela",
    location: "Rourkela",
    established_year: 1961,
    nirfrank: 9,
    class: :NIT
  },
  %{
    name: "Indian Institute of Information Technology, Allahabad",
    location: "Allahabad",
    established_year: 1999,
    nirfrank: 10,
    class: :IIIT
  }
]

Enum.each(colleges, fn college ->
  {:ok, created_college} =
    Repo.insert(%College{
      name: college.name,
      location: college.location,
      established_year: college.established_year,
      nirfrank: college.nirfrank,
      class: college.class,
      link_to_website: "https://#{String.downcase(String.replace(college.name, ", ", ""))}.ac.in",
      campus_area: :rand.uniform(1000) + 100
    })

  # Assign 3-5 random branches to each college
  num_branches = :rand.uniform(3) + 2
  college_branches = Enum.take_random(created_branches, num_branches)

  Enum.each(college_branches, fn branch ->
    Repo.insert(%CollegeBranch{college_id: created_college.id, branch_id: branch.id})
  end)
end)

IO.puts("Seeding completed successfully!")
