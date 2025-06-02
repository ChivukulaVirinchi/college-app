defmodule CounsellingWeb.ProgramLive.CustomHeader do
  use Phoenix.Component
  alias LiveTable.Boolean
  import CounsellingWeb.CoreComponents

  def custom_header(assigns) do
    ~H"""
    <div>
      <.form for={%{}} phx-debounce={get_in(@table_options, [:search, :debounce])} phx-change="sort">
        <section class="relative mb-8 -mt-6 sm:mb-10 sm:-mt-10 lg:mb-12 lg:-mt-16">
          <div class="bg-white dark:bg-gray-800 shadow-2xl border border-gray-100 dark:border-gray-700 rounded-xl sm:rounded-2xl overflow-hidden">
            <div class="p-6 sm:p-8 lg:p-10">
              <!-- Helper Info -->
              <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                <div class="flex items-start space-x-3">
                  <svg class="w-5 h-5 mt-0.5 text-blue-600 dark:text-blue-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <div class="text-sm text-blue-800 dark:text-blue-200">
                    <strong>Program Guide:</strong> Each program shows opening/closing ranks for different quotas (All India, Home State, Other State) and categories. Enter your rank in the college filters to see personalized eligibility across all programs.
                  </div>
                </div>
              </div>

              <!-- Quick Search -->
              <div class="mb-8 p-6 bg-gradient-to-r from-violet-50 to-purple-50 dark:from-violet-900/20 dark:to-purple-900/20 border border-violet-200 dark:border-violet-800 rounded-xl sm:p-8">
                <div class="flex items-center mb-6 sm:mb-8">
                  <div class="w-1 h-8 mr-4 bg-gradient-to-b from-violet-500 to-purple-600 rounded-full sm:h-10 sm:mr-5">
                  </div>
                  <h3 class="text-xl font-bold text-violet-900 dark:text-violet-100 sm:text-2xl">
                    Find Your Program
                  </h3>
                </div>
                <div class="grid gap-4 lg:grid-cols-3 lg:gap-6">
                  <!-- Search Field - Full width on mobile, 1/3 on large screens -->
                  <div class="lg:col-span-1">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Search Programs <span class="text-xs text-gray-500">(By branch name or specialization)</span>
                    </label>
                    <div class="relative">
                      <input
                        type="text"
                        name="search"
                        autocomplete="off"
                        id="college-search"
                        value={@options["filters"]["search"]}
                        placeholder="e.g., Computer Science, Mechanical..."
                        class="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-violet-500 transition-colors shadow-sm"
                      />
                      <svg
                        class="absolute left-3 top-3 w-4 h-4 text-gray-400"
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
                  </div>
                  
    <!-- Filter Groups - Stack on mobile, side by side on large screens -->
                  <div class="grid gap-4 sm:grid-cols-2 lg:col-span-2 lg:gap-6">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        Degree Type <span class="text-xs text-gray-500">(B.Tech, M.Tech, etc.)</span>
                      </label>
                      <div class="grid grid-cols-1 gap-2 sm:grid-cols-2 lg:grid-cols-3">
                        <.input
                          :for={
                            {id, %Boolean{key: "degree_type", options: %{label: label}}} <- @filters
                          }
                          type="checkbox"
                          name={"filters[#{id}]"}
                          label={label}
                          checked={Map.has_key?(@options["filters"], id)}
                        />
                      </div>
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        Duration <span class="text-xs text-gray-500">(4 years for B.Tech, 2 years for M.Tech)</span>
                      </label>
                      <div class="grid grid-cols-1 gap-2 sm:grid-cols-2 lg:grid-cols-3">
                        <.input
                          :for={{id, %Boolean{key: "duration", options: %{label: label}}} <- @filters}
                          type="checkbox"
                          name={"filters[#{id}]"}
                          label={label}
                          checked={Map.has_key?(@options["filters"], id)}
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="flex items-center justify-end pt-6 mt-6 border-t border-gray-200 dark:border-gray-600">
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
      </.form>
    </div>
    """
  end
end
