defmodule CounsellingWeb.CollegeLive.CustomHeader do
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
              <div class="flex-1 min-w-[120px] max-w-[180px]">
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

        <%!-- Row 2: Search + NIRF + Sort (single form for persistence) --%>
        <div class="px-5 py-4 sm:px-6 border-t border-stone-200/60 dark:border-zinc-800">
          <.form
            for={%{}}
            phx-debounce={get_in(@table_options, [:search, :debounce])}
            phx-change="sort"
          >
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <.input
                type="text"
                name="search"
                id="college-search"
                placeholder="Search colleges..."
                value={@options["filters"]["search"]}
                autocomplete="off"
              />

              <div id="nirf-select-wrapper" phx-update="ignore">
                <.select
                  id="nirf-select"
                  name="filters[limit_results][nirf]"
                  value={nirf_value(@options)}
                >
                  <.select_option value="All Rankings" label="All Rankings" />
                  <.select_option value="Top 10" label="Top 10" />
                  <.select_option value="Top 25" label="Top 25" />
                  <.select_option value="Top 50" label="Top 50" />
                  <.select_option value="Top 100" label="Top 100" />
                </.select>
              </div>

              <div id="sort-select-wrapper" phx-update="ignore">
                <.select
                  id="sort-select"
                  name="filters[sort_mode][sort_by]"
                  value={sort_value(@options)}
                >
                  <.select_option value="NIRF Ranking" label="NIRF Ranking" />
                  <.select_option
                    value="Established Year"
                    label="Established Year"
                  />
                  <.select_option value="Name (A-Z)" label="Name (A-Z)" />
                  <.select_option value="Name (Z-A)" label="Name (Z-A)" />
                </.select>
              </div>
            </div>
          </.form>
        </div>

        <%!-- Row 3: Institution type pill toggles + Clear --%>
        <div class="px-5 py-4 sm:px-6 border-t border-stone-200/60 dark:border-zinc-800">
          <div class="flex flex-wrap items-center gap-2">
            <.form
              for={%{}}
              phx-debounce={get_in(@table_options, [:search, :debounce])}
              phx-change="sort"
              class="contents"
            >
              <label
                :for={{id, %Boolean{field: :class, options: %{label: label}}} <- @filters}
                class={[
                  "relative px-4 py-1.5 rounded-full text-sm font-medium cursor-pointer transition-all duration-200 select-none border",
                  pill_color(id, Map.has_key?(@options["filters"], id))
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

  defp nirf_value(options) do
    (Map.get(options["filters"], :limit_results) &&
       Map.get(options["filters"], :limit_results).options.applied_data["nirf"]) ||
      "All Rankings"
  end

  defp sort_value(options) do
    (Map.get(options["filters"], :sort_mode) &&
       Map.get(options["filters"], :sort_mode).options.applied_data["sort_by"]) ||
      "NIRF Ranking"
  end

  # Active (checked) pill colors
  defp pill_color(:iit, true),
    do: "bg-violet-600 text-white border-violet-600 dark:bg-violet-500 dark:border-violet-500"

  defp pill_color(:nit, true),
    do: "bg-blue-600 text-white border-blue-600 dark:bg-blue-500 dark:border-blue-500"

  defp pill_color(:iiit, true),
    do:
      "bg-emerald-600 text-white border-emerald-600 dark:bg-emerald-500 dark:border-emerald-500"

  defp pill_color(:gfti, true),
    do:
      "bg-orange-600 text-white border-orange-600 dark:bg-orange-500 dark:border-orange-500"

  # Inactive (unchecked) pill colors
  defp pill_color(:iit, false),
    do:
      "bg-transparent text-violet-600 border-violet-300 hover:bg-violet-50 dark:text-violet-400 dark:border-violet-700 dark:hover:bg-violet-900/30"

  defp pill_color(:nit, false),
    do:
      "bg-transparent text-blue-600 border-blue-300 hover:bg-blue-50 dark:text-blue-400 dark:border-blue-700 dark:hover:bg-blue-900/30"

  defp pill_color(:iiit, false),
    do:
      "bg-transparent text-emerald-600 border-emerald-300 hover:bg-emerald-50 dark:text-emerald-400 dark:border-emerald-700 dark:hover:bg-emerald-900/30"

  defp pill_color(:gfti, false),
    do:
      "bg-transparent text-orange-600 border-orange-300 hover:bg-orange-50 dark:text-orange-400 dark:border-orange-700 dark:hover:bg-orange-900/30"

  # Fallback
  defp pill_color(_, true),
    do: "bg-stone-900 text-white border-stone-900 dark:bg-zinc-100 dark:text-zinc-900"

  defp pill_color(_, false),
    do:
      "bg-transparent text-stone-500 border-stone-300 hover:bg-stone-50 dark:text-zinc-400 dark:border-zinc-700 dark:hover:bg-zinc-800/50"
end
