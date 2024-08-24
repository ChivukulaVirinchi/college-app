defmodule CounsellingWeb.CollegeComponent do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: CounsellingWeb.Endpoint, router: CounsellingWeb.Router

  def college_component(assigns) do
    ~H"""
    <div class="w-full max-w-xs border border-gray-100 rounded-lg shadow md:max-w-sm bg-gray-50">
      <img
        src="https://img.studyclap.com/img/institute/college/1342_3iitm3.png"
        alt="College Image"
        class="object-cover w-full h-48 rounded-t-lg"
      />
      <div class="grid gap-4 p-6">
        <div class="grid grid-cols-1 gap-2">
          <div>
            <h2 class="text-xl font-bold md:text-2xl"><%= @college.name %></h2>
            <p class="text-sm text-gray-600"><%= @college.location %></p>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-lg font-medium">
              <%= nirf_helper(Counselling.Colleges.get_college_rank(@college.id).nirf_rank) %>
            </p>
            <p class="text-sm text-gray-600">NIRF Rank</p>
          </div>

          <%!-- <div>
            <p class="text-lg font-medium">92%</p>
            <p class="text-sm text-gray-600">Avg. Placement</p>
          </div>
          <div>
            <p class="text-lg font-medium">₹8.2 LPA</p>
            <p class="text-sm text-gray-600">Median Salary</p>
          </div>
          <div>
            <p class="text-lg font-medium">15:1</p>
            <p class="text-sm text-gray-600">Student-Faculty Ratio</p>
          </div> --%>
          <%!-- </div>
        <div class="grid grid-cols-2 gap-4"> --%>
          <%!-- <div>
            <p class="text-lg font-medium">A++</p>
            <p class="text-sm text-gray-600">NAAC Grade</p>
          </div> --%>
          <div>
            <p class="text-lg font-medium"><%= @college.campus_area %> Acres</p>
            <p class="text-sm text-gray-600">Campus Size</p>
          </div>
          <%!-- <div>
            <p class="text-lg font-medium">250+</p>
            <p class="text-sm text-gray-600">Companies Visiting</p>
          </div>
          <div>
            <p class="text-lg font-medium">1000+</p>
            <p class="text-sm text-gray-600">Internships</p>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-lg font-medium">500+ Papers, 50+ Patents</p>
            <p class="text-sm text-gray-600">Research Output</p>
          </div>
          <div>
            <p class="text-lg font-medium">50,000+</p>
            <p class="text-sm text-gray-600">Alumni Network</p>
          </div> --%>
          <div>
            <p class="text-lg font-medium"><%= @college.established_year %></p>
            <p class="text-sm text-gray-600">Established Year</p>
          </div>
        </div>
      </div>
      <div class="flex px-6 py-4 space-x-2 border-t border-gray-300/70">
        <.link
          patch={~p"/colleges/#{@college}"}
          class="px-4 py-2 text-xs font-medium text-white transition-colors rounded-md shadow lg:text-sm bg-violet-600 hover:bg-violet-700 focus:outline-none"
        >
          View College
        </.link>
        <.link
          href={@college.link_to_website}
          class="inline-flex px-4 py-2 text-sm font-medium transition-colors bg-white border rounded-md shadow-sm border-violet-600 text-violet-600 hover:bg-gray-50 focus:outline-none"
        >
          Visit Website
        </.link>
      </div>
    </div>
    """
  end

  def nirf_helper(rank) do
    cond do
      rank == 500 -> "-"
      rank == 125 -> "100 - 150"
      rank == 175 -> "150 - 200"
      true -> rank
    end
  end
end
