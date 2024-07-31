defmodule CounsellingWeb.CollegeComponent do
  alias Counselling.Colleges.College
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: CounsellingWeb.Endpoint, router: CounsellingWeb.Router

  # def college_component(assigns) do
  #   ~H"""
  #   <div class="relative group bg-white border border-gray-300 shadow-sm rounded-xl ark:bg-neutral-900 ark:border-neutral-700 ark:shadow-neutral-700/70">
  #     <div class="z-0 bg-gradient-to-t from-gray-800 to-gray-200 group-hover:from-black hover:to-bg-gray-300 rounded-t-xl">
  #       <img
  #         class="opacity-80 rounded-t-xl object-cover "
  #         src="https://img.studyclap.com/img/institute/college/1342_3iitm3.png"
  #         alt="Card Image"
  #       />
  #     </div>
  #     <div class="absolute top-0 right-0 w-16 h-16">
  #       <svg
  #         class="size-18 fill-current text-violet-600"
  #         viewBox="0 0 586 496"
  #         xmlns="http://www.w3.org/2000/svg"
  #       >
  #         <path d="M230.536 292.88C81.1359 319.08 131.286 238.297 175.036 194.63C83.6787 203.587 -71.6285 177.2 38.0001 0.000153709C188 -2.93965e-05 533 -7.19735e-05 710.036 0.000153709L732.786 73.3803C864.036 86.1303 869.036 247.63 710.036 229.88C803.536 305.63 702.536 441.88 591.286 406.38C593.786 492.13 417.286 555.38 369.286 406.38C190.036 474.38 175.036 373.63 230.536 292.88Z" />
  #       </svg>
  #       <span class="absolute top-3 right-3 text-white font-bold text-2xl">
  #         <%= @college.nirfrank %>
  #       </span>
  #     </div>
  #     <div class="relative -top-8 px-1 flex w-full justify-between">
  #       <%!-- <h1 class="text-white text-s">Indian Institute of Technology Madras</h1> --%>
  #       <h1 class="text-white text-xl font-semibold"><%= @college.name %></h1>
  #       <div>
  #         <svg
  #           class="w-4 h-4 inline-flex -mr-1 text-white"
  #           data-slot="icon"
  #           fill="none"
  #           stroke-width="1.5"
  #           stroke="currentColor"
  #           viewBox="0 0 24 24"
  #           xmlns="http://www.w3.org/2000/svg"
  #           aria-hidden="true"
  #         >
  #           <path
  #             stroke-linecap="round"
  #             stroke-linejoin="round"
  #             d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
  #           >
  #           </path>
  #           <path
  #             stroke-linecap="round"
  #             stroke-linejoin="round"
  #             d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"
  #           >
  #           </path>
  #         </svg>
  #         <span class="text-xs text-white"><%= @college.location %></span>
  #       </div>
  #     </div>
  #     <div class="bg-gray-100 p-4 -mt-6">
  #       <ul class="grid grid-cols-2">
  #         <li>
  #           <svg
  #             class="size-4 inline-flex"
  #             data-slot="icon"
  #             fill="none"
  #             stroke-width="2"
  #             stroke="currentColor"
  #             viewBox="0 0 24 24"
  #             xmlns="http://www.w3.org/2000/svg"
  #             aria-hidden="true"
  #           >
  #             <path
  #               stroke-linecap="round"
  #               stroke-linejoin="round"
  #               d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5"
  #             >
  #             </path>
  #           </svg>
  #           <span class="text-xs align-middle pb-1"><%= @college.established_year %></span>
  #         </li>
  #         <li class="text-gray-600">
  #           <svg
  #             class="h-5 w-5 inline-flex"
  #             data-slot="icon"
  #             fill="none"
  #             stroke-width="1.3"
  #             stroke="currentColor"
  #             viewBox="0 0 24 24"
  #             xmlns="http://www.w3.org/2000/svg"
  #             aria-hidden="true"
  #           >
  #             <path
  #               stroke-linecap="round"
  #               stroke-linejoin="round"
  #               d="M15 8.25H9m6 3H9m3 6-3-3h1.5a3 3 0 1 0 0-6M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
  #             >
  #             </path>
  #           </svg>
  #           <span class="text-xs"><b class="text-gray-700">45L</b> (Highest)</span>
  #         </li>
  #         <li class="text-gray-600">
  #           <svg
  #             class="h-4 w-4 inline-flex"
  #             data-slot="icon"
  #             fill="none"
  #             stroke-width="1.5"
  #             stroke="currentColor"
  #             viewBox="0 0 24 24"
  #             xmlns="http://www.w3.org/2000/svg"
  #             aria-hidden="true"
  #           >
  #             <path
  #               stroke-linecap="round"
  #               stroke-linejoin="round"
  #               d="M9 6.75V15m6-6v8.25m.503 3.498 4.875-2.437c.381-.19.622-.58.622-1.006V4.82c0-.836-.88-1.38-1.628-1.006l-3.869 1.934c-.317.159-.69.159-1.006 0L9.503 3.252a1.125 1.125 0 0 0-1.006 0L3.622 5.689C3.24 5.88 3 6.27 3 6.695V19.18c0 .836.88 1.38 1.628 1.006l3.869-1.934c.317-.159.69-.159 1.006 0l4.994 2.497c.317.158.69.158 1.006 0Z"
  #             >
  #             </path>
  #           </svg>
  #           <span class="text-xs">
  #             <b class="text-gray-700"> <%= @college.campus_area %> </b>Acres
  #           </span>
  #         </li>

  #         <li class="text-gray-600">
  #           <svg
  #             class="h-4 w-4 inline-flex"
  #             data-slot="icon"
  #             fill="none"
  #             stroke-width="1.3"
  #             stroke="currentColor"
  #             viewBox="0 0 24 24"
  #             xmlns="http://www.w3.org/2000/svg"
  #             aria-hidden="true"
  #           >
  #             <path
  #               stroke-linecap="round"
  #               stroke-linejoin="round"
  #               d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z"
  #             >
  #             </path>
  #           </svg>
  #           <span class="text-xs"><b class="text-gray-700">3.4L</b> (First Year)</span>
  #         </li>
  #         <li class="text-gray-600">
  #           <svg
  #             xmlns="http://www.w3.org/2000/svg"
  #             class="h-4 w-4 inline-flex"
  #             viewBox="0 0 20 20"
  #             fill="currentColor"
  #           >
  #             <path
  #               fill-rule="evenodd"
  #               d="M4 4a2 2 0 012-2h8a2 2 0 012 2v12a1 1 0 110 2h-3a1 1 0 01-1-1v-2a1 1 0 00-1-1H9a1 1 0 00-1 1v2a1 1 0 01-1 1H4a1 1 0 110-2V4zm3 1h2v2H7V5zm2 4H7v2h2V9zm2-4h2v2h-2V5zm2 4h-2v2h2V9z"
  #               clip-rule="evenodd"
  #             />
  #           </svg>
  #           <span class="text-xs">Government</span>
  #         </li>
  #         <li class="text-gray-600">
  #           <svg
  #             class="h-4 w-4 inline-flex ml-0.5 text-gray-700"
  #             data-slot="icon"
  #             fill="none"
  #             stroke-width="1.5"
  #             stroke="currentColor"
  #             viewBox="0 0 24 24"
  #             xmlns="http://www.w3.org/2000/svg"
  #             aria-hidden="true"
  #           >
  #             <path
  #               stroke-linecap="round"
  #               stroke-linejoin="round"
  #               d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 0 0 1.5-1.5V6a1.5 1.5 0 0 0-1.5-1.5H3.75A1.5 1.5 0 0 0 2.25 6v12a1.5 1.5 0 0 0 1.5 1.5Zm10.5-11.25h.008v.008h-.008V8.25Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z"
  #             >
  #             </path>
  #           </svg>
  #           <span class="text-xs">Gym, Ground</span>
  #         </li>
  #       </ul>
  #       <p class="text-xs mt-2">
  #         Lorem, ipsum dolor sit amet consectetur adipisicing elit. Corrupti aspernatur delectus nisi minima.
  #       </p>
  #       <div class="mt-2">
  #         <.link
  #           class="py-2 px-3  text-sm font-medium rounded-lg  bg-violet-600 text-white hover:bg-violet-700 focus:outline-none focus:bg-violet-700"
  #           navigate={~p"/colleges/#{@college.id}"}
  #         >
  #           Explore College
  #         </.link>
  #         <a
  #           class="py-2 px-3 text-sm font-medium rounded-lg bg-violet-100 text-violet-600 hover:bg-violet-200 hover:text-violet-700 focus:outline-none focus:bg-violet-200"
  #           href="#"
  #         >
  #           College Website
  #         </a>
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  # def college_component(assigns) do
  #   ~H"""
  #   <div class="w-full max-w-md">
  #     <img
  #       src="https://img.studyclap.com/img/institute/college/1342_3iitm3.png"
  #       width={400}
  #       height={200}
  #       alt="College Photo"
  #       class="rounded-t-lg object-cover"
  #     />
  #     <div class="p-6 space-y-4">
  #       <div class="space-y-2">
  #         <h3 class="text-xl font-semibold"><%= @college.name %></h3>
  #         <div class="flex items-center gap-2 text-sm text-muted-foreground">
  #           <svg
  #             class="size-4"
  #             xmlns="http://www.w3.org/2000/svg"
  #             width="24"
  #             height="24"
  #             viewBox="0 0 24 24"
  #             fill="none"
  #             stroke="currentColor"
  #             strokeWidth="2"
  #             strokeLinecap="round"
  #             strokeLinejoin="round"
  #           >
  #             <line x1="2" x2="5" y1="12" y2="12" />
  #             <line x1="19" x2="22" y1="12" y2="12" />
  #             <line x1="12" x2="12" y1="2" y2="5" />
  #             <line x1="12" x2="12" y1="19" y2="22" />
  #             <circle cx="12" cy="12" r="7" />
  #           </svg>
  #           Rourkela, Odisha
  #         </div>
  #       </div>
  #       <div class="grid grid-cols-2 gap-4">
  #         <div class="space-y-1">
  #           <div class="text-sm font-medium">NIRF Ranking</div>
  #           <div class="text-2xl font-semibold">9</div>
  #         </div>
  #         <div class="space-y-1">
  #           <div class="text-sm font-medium">Established</div>
  #           <div class="text-2xl font-semibold">1961</div>
  #         </div>
  #         <div class="space-y-1">
  #           <div class="text-sm font-medium">Acceptance Rate</div>
  #           <div class="text-2xl font-semibold">12%</div>
  #         </div>
  #         <div class="space-y-1">
  #           <div class="text-sm font-medium">Student Population</div>
  #           <div class="text-2xl font-semibold">6,000</div>
  #         </div>
  #       </div>
  #       <div class="flex gap-2">
  #         <a
  #           href="#"
  #           target="_blank"
  #           class="flex-1 inline-flex h-10 items-center justify-center rounded-md bg-violet-500 text-violet-100 px-4 text-sm font-medium shadow transition-colors  focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring isabled:opacity-50"
  #           prefetch={false}
  #         >
  #           Visit Website
  #         </a>
  #         <a
  #           href="#"
  #           class="flex-1 inline-flex h-10 items-center justify-center rounded-md border border-input bg-violet-100 text-violet-600 px-4 text-sm font-medium shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50"
  #           prefetch={false}
  #         >
  #           View College
  #         </a>
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  def college_component(assigns) do
    ~H"""
    <div class="w-full max-w-md bg-gray-100 border border-gray-300/70 rounded-lg shadow">
      <img
        src="https://img.studyclap.com/img/institute/college/1342_3iitm3.png"
        alt="College Image"
        class="rounded-t-lg w-full h-48 object-cover"
      />
      <div class="p-6 grid gap-4">
        <div class="grid grid-cols-1 gap-2">
          <div>
            <h2 class="text-2xl font-bold"><%= @college.name %></h2>
            <p class="text-sm text-gray-600"><%= @college.location %></p>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-lg font-medium"><%= @college.nirfrank %></p>
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
      <div class="flex space-x-2 px-6 py-4 border-t border-gray-300/70">
        <.link
          patch={~p"/colleges/#{@college}"}
          class="inline-flex rounded-md bg-violet-600 px-4 py-2 text-sm font-medium text-white shadow transition-colors hover:bg-violet-700 focus:outline-none"
        >
          View College
        </.link>
        <.link
          href={@college.link_to_website}
          class="inline-flex rounded-md border border-violet-600 bg-white px-4 py-2 text-sm font-medium text-violet-600 shadow-sm transition-colors hover:bg-gray-50 focus:outline-none"
        >
          Visit Website
        </.link>
      </div>
    </div>
    """
  end
end
