defmodule CounsellingWeb.ProgramLive.CustomHeader do
  use CounsellingWeb, :html
  alias LiveTable.Boolean

  def custom_header(assigns) do
    ~H"""
    <.card>
      <:content class="p-0!">
        <%!-- Row 1: Rank finder --%>
        <div class="relative px-5 py-4 sm:px-6">
          <div class="absolute top-0 left-0 w-1 h-full bg-amber-500 rounded-r" />
          <h2 class="text-sm font-semibold text-stone-700 dark:text-zinc-200 mb-3">
            Find Colleges for Your Rank
          </h2>
          <div class="flex flex-wrap items-center gap-3">
            <.form
              for={%{}}
              phx-debounce={get_in(@table_options, [:search, :debounce])}
              phx-change="sort"
              class="contents"
            >
              <div class="flex-1 min-w-[120px] max-w-[180px] [&_.fieldset]:mb-0">
                <.input
                  type="number"
                  phx-hook="RankInput"
                  id="rank-input"
                  placeholder="JEE Rank"
                  name="filters[rank][value]"
                  value={
                    Map.get(@options["filters"], :rank) &&
                      Map.get(@options["filters"], :rank).options.applied_data["value"]
                  }
                />
              </div>
            </.form>
            <div
              id="category-select-wrapper"
              phx-update="ignore"
              phx-hook="CategorySelect"
              class="min-w-[140px]"
            >
              <.select id="category-select" name="category" value="open">
                <.select_option value="open" label="OPEN" />
                <.select_option value="obc_ncl" label="OBC-NCL" />
                <.select_option value="sc" label="SC" />
                <.select_option value="st" label="ST" />
                <.select_option value="ews" label="EWS" />
                <.select_option value="open_pwd" label="OPEN (PwD)" />
                <.select_option value="obc_ncl_pwd" label="OBC-NCL (PwD)" />
                <.select_option value="sc_pwd" label="SC (PwD)" />
                <.select_option value="st_pwd" label="ST (PwD)" />
                <.select_option value="ews_pwd" label="EWS (PwD)" />
              </.select>
            </div>
          </div>
        </div>

        <%!-- Row 2: Search + Degree Type (single form for persistence) --%>
        <div class="px-5 py-4 sm:px-6 border-t border-stone-200/60 dark:border-zinc-800">
          <.form
            for={%{}}
            phx-debounce={get_in(@table_options, [:search, :debounce])}
            phx-change="sort"
          >
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <.input
                type="text"
                name="search"
                id="college-search"
                placeholder="Search programs..."
                value={@options["filters"]["search"]}
                autocomplete="off"
              />

              <div id="degree-type-select-wrapper" phx-update="ignore">
                <.select
                  id="degree-type-select"
                  name="filters[limit_results][degree_type]"
                  value={degree_value(@options)}
                  searchable
                  search_placeholder="Search degrees..."
                >
                  <.select_option value="All Degrees" label="All Degrees" />
                  <.select_option
                    :for={dt <- Counselling.Programs.list_program_types()}
                    value={dt}
                    label={dt}
                  />
                </.select>
              </div>
            </div>
          </.form>
        </div>

        <%!-- Row 3: Duration pill toggles + Clear --%>
        <div class="px-5 py-4 sm:px-6 border-t border-stone-200/60 dark:border-zinc-800">
          <div class="flex flex-wrap items-center gap-2">
            <.form
              for={%{}}
              phx-debounce={get_in(@table_options, [:search, :debounce])}
              phx-change="sort"
              class="contents"
            >
              <label
                :for={
                  {id, %Boolean{field: :duration, options: %{label: label}}} <- @filters
                }
                class={[
                  "relative px-4 py-1.5 rounded-full text-sm font-medium cursor-pointer transition-all duration-200 select-none border",
                  if(Map.has_key?(@options["filters"], id),
                    do:
                      "bg-amber-500 text-white border-amber-500 dark:bg-amber-500 dark:border-amber-500",
                    else:
                      "bg-transparent text-stone-600 border-stone-300 hover:bg-amber-50 dark:text-zinc-400 dark:border-zinc-700 dark:hover:bg-amber-900/20"
                  )
                ]}
              >
                <input type="hidden" name={"filters[#{id}]"} value="false" />
                <input
                  type="checkbox"
                  name={"filters[#{id}]"}
                  value="true"
                  checked={Map.has_key?(@options["filters"], id)}
                  class="sr-only"
                />
                {label}
              </label>
            </.form>

            <.button
              :if={@options["filters"] != %{"search" => ""}}
              variant="ghost"
              size="sm"
              phx-click="sort"
              phx-value-clear_filters="true"
            >
              Clear filters
            </.button>
          </div>
        </div>
      </:content>
    </.card>
    """
  end

  defp degree_value(options) do
    (Map.get(options["filters"], :limit_results) &&
       Map.get(options["filters"], :limit_results).options.applied_data["degree_type"]) ||
      "All Degrees"
  end
end
