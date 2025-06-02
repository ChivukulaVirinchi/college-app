defmodule CounsellingWeb.CollegeLive.CustomHeader do
  use Phoenix.Component
  alias LiveTable.Boolean
  import CounsellingWeb.CoreComponents

  def custom_header(assigns) do
    ~H"""
    <div>
      <section class="relative mb-6 -mt-4 sm:mb-8 sm:-mt-8 lg:mb-12 lg:-mt-12">
        <div class="bg-white dark:bg-gray-800 shadow-2xl border border-gray-100 dark:border-gray-700 rounded-xl sm:rounded-2xl">
          <div class="p-4 sm:p-6 lg:p-8">
            <div class="mb-6 p-4 bg-gradient-to-r from-violet-50 to-purple-50 dark:from-violet-900/20 dark:to-purple-900/20 border border-violet-200 dark:border-violet-800 rounded-xl sm:p-6">
              <div class="flex items-center mb-3 sm:mb-4">
                <div class="w-1 h-6 mr-3 bg-gradient-to-b from-violet-500 to-purple-600 rounded-full sm:h-8 sm:mr-4">
                </div>
                <h3 class="text-lg font-bold text-violet-900 dark:text-violet-100 sm:text-xl">
                  Find Colleges for Your Rank
                </h3>
              </div>
              <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 sm:gap-4">
                <div>
                  <.form
                    for={%{}}
                    phx-debounce={get_in(@table_options, [:search, :debounce])}
                    phx-change="sort"
                  >
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Your JEE Rank
                      <span class="text-xs text-gray-500">
                        (Saved automatically, filters all pages)
                      </span>
                    </label>
                    <input
                      type="number"
                      phx-hook="RankInput"
                      id="rank-input"
                      placeholder="e.g., 15000"
                      name="filters[rank][value]"
                      value={
                        Map.get(@options["filters"], :rank) &&
                          Map.get(@options["filters"], :rank).options.applied_data["value"]
                      }
                      class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                    />
                  </.form>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Category
                    <span class="text-xs text-gray-500">(Select your reservation category)</span>
                  </label>
                  <select class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors">
                    <option>General</option>
                    <option>OBC-NCL</option>
                    <option>SC</option>
                    <option>ST</option>
                    <option>EWS</option>
                  </select>
                </div>
                <%!-- <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Quota
                    </label>
                    <select
                      phx-change="handle-location"
                      class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                    >
                      <option>All India</option>
                      <option>Home State</option>
                    </select>
                  </div> --%>
              </div>
            </div>

            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-6">
              <div>
                <.form
                  for={%{}}
                  phx-debounce={get_in(@table_options, [:search, :debounce])}
                  phx-change="sort"
                >
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Search Colleges <span class="text-xs text-gray-500">(By name or location)</span>
                  </label>
                  <div class="relative">
                    <input
                      type="text"
                      name="search"
                      autocomplete="off"
                      id="college-search"
                      value={@options["filters"]["search"]}
                      placeholder="Search by name or location..."
                      class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                    />
                    <svg
                      class="absolute left-3 top-2.5 w-4 h-4 text-gray-400"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                      >
                      </path>
                    </svg>
                  </div>
                </.form>
              </div>

              <%!-- <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Your Location (Optional)
                  </label>
                  <div class="relative">
                    <input
                      type="text"
                      placeholder="Enter city or auto-detect"
                      class="w-full pl-10 pr-10 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                    />
                    <svg
                      class="absolute left-3 top-2.5 w-4 h-4 text-gray-400"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                      >
                      </path>
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                      >
                      </path>
                    </svg>
                    <button
                      class="absolute right-2 top-2 p-1 text-gray-400 hover:text-violet-600 dark:hover:text-violet-400 transition-colors"
                      title="Auto-detect location"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M13 10V3L4 14h7v7l9-11h-7z"
                        >
                        </path>
                      </svg>
                    </button>
                  </div>
                </div> --%>
              <%!-- <div>
                <.form
                  for={%{}}
                  phx-debounce={get_in(@table_options, [:search, :debounce])}
                  phx-change="sort"
                >
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    NIRF Ranking <span class="text-xs text-gray-500">(Filter by government rankings)</span>
                  </label>
                  <select
                    value={get_in(@options, ["filters", "limit_results", "nirf"]) || "All Rankings"}
                    name="filters[limit_results][nirf]"
                    phx-change="sort"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                  >
                    <option
                      value="All Rankings"
                      selected={
                        get_in(@options, ["filters", "limit_results", "nirf"]) == "All Rankings"
                      }
                    >
                      All Rankings
                    </option>
                    <option
                      value="Top 10"
                      selected={get_in(@options, ["filters", "limit_results", "nirf"]) == "Top 10"}
                    >
                      Top 10
                    </option>
                    <option
                      value="Top 25"
                      selected={get_in(@options, ["filters", "limit_results", "nirf"]) == "Top 25"}
                    >
                      Top 25
                    </option>
                    <option
                      value="Top 50"
                      selected={get_in(@options, ["filters", "limit_results", "nirf"]) == "Top 50"}
                    >
                      Top 50
                    </option>
                    <option
                      value="Top 100"
                      selected={get_in(@options, ["filters", "limit_results", "nirf"]) == "Top 100"}
                    >
                      Top 100
                    </option>
                  </select>
                </.form>
              </div> --%>

              <div>
                <.form
                  for={%{}}
                  phx-debounce={get_in(@table_options, [:search, :debounce])}
                  phx-change="sort"
                >
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    NIRF Ranking
                  </label>
                  <select
                    name="filters[limit_results][nirf]"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                  >
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "All Rankings"
                    }>
                      All Rankings
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Top 10"
                    }>
                      Top 10
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Top 25"
                    }>
                      Top 25
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Top 50"
                    }>
                      Top 50
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Top 100"
                    }>
                      Top 100
                    </option>
                  </select>
                </.form>
              </div>
              <div>
                <.form
                  for={%{}}
                  phx-debounce={get_in(@table_options, [:search, :debounce])}
                  phx-change="sort"
                >
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    Sort By <span class="text-xs text-gray-500">(Change display order)</span>
                  </label>
                  <select
                    value={@options["filters"]["sort_mode"]["sort_by"] || "NIRF Ranking"}
                    name="filters[sort_mode][sort_by]"
                    class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors"
                  >
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "NIRF Ranking"
                    }>
                      NIRF Ranking
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Established Year"
                    }>
                      Established Year
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Name (A-Z)"
                    }>
                      Name (A-Z)
                    </option>
                    <option selected={
                      Map.get(@options["filters"], :limit_results) &&
                        Map.get(@options["filters"], :limit_results).options.applied_data["nirf"] ==
                          "Name (Z-A)"
                    }>
                      Name (Z-A)
                    </option>
                  </select>
                </.form>
              </div>
            </div>

            <div class="mb-4">
              <.form
                for={%{}}
                phx-debounce={get_in(@table_options, [:search, :debounce])}
                phx-change="sort"
              >
                <span class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                  Institution Type
                  <span class="text-xs text-gray-500">
                    (IIT = Premier institutes, NIT = National institutes, IIIT = Information technology, GFTI = Government funded)
                  </span>
                </span>
                <div class="flex flex-wrap gap-x-6">
                  <.input
                    :for={{id, %Boolean{field: :class, options: %{label: label}}} <- @filters}
                    type="checkbox"
                    name={"filters[#{id}]"}
                    label={label}
                    checked={Map.has_key?(@options["filters"], id)}
                  />
                </div>
              </.form>
            </div>

            <div class="flex items-center justify-end pt-4 border-t border-gray-200 dark:border-gray-600 h-6">
              <.link
                :if={@options["filters"] != %{"search" => ""}}
                phx-click="sort"
                phx-value-clear_filters="true"
                class="my-auto text-sm text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300 transition-colors"
              >
                Clear All Filters
              </.link>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
