defmodule CounsellingWeb.CollegeComponent2 do
  use CounsellingWeb, :html
  alias CounsellingWeb.RankComponent
  import CounsellingWeb.CollegeLive.Show, only: [nirf_helper: 1]

  @seat_type_colors %{
    open: "text-stone-700 dark:text-zinc-300",
    obc_ncl: "text-blue-600 dark:text-blue-400",
    sc: "text-emerald-600 dark:text-emerald-400",
    st: "text-orange-600 dark:text-orange-400",
    ews: "text-amber-600 dark:text-amber-400",
    open_pwd: "text-stone-700 dark:text-zinc-300",
    obc_ncl_pwd: "text-blue-600 dark:text-blue-400",
    sc_pwd: "text-emerald-600 dark:text-emerald-400",
    st_pwd: "text-orange-600 dark:text-orange-400",
    ews_pwd: "text-amber-600 dark:text-amber-400"
  }

  @seat_type_bg %{
    open: "bg-stone-50 dark:bg-zinc-800/50",
    obc_ncl: "bg-blue-50 dark:bg-blue-900/20",
    sc: "bg-emerald-50 dark:bg-emerald-900/20",
    st: "bg-orange-50 dark:bg-orange-900/20",
    ews: "bg-amber-50 dark:bg-amber-900/20",
    open_pwd: "bg-stone-50 dark:bg-zinc-800/50",
    obc_ncl_pwd: "bg-blue-50 dark:bg-blue-900/20",
    sc_pwd: "bg-emerald-50 dark:bg-emerald-900/20",
    st_pwd: "bg-orange-50 dark:bg-orange-900/20",
    ews_pwd: "bg-amber-50 dark:bg-amber-900/20"
  }

  @seat_type_labels %{
    open: "OPEN",
    obc_ncl: "OBC-NCL",
    sc: "SC",
    st: "ST",
    ews: "EWS",
    open_pwd: "OPEN (PwD)",
    obc_ncl_pwd: "OBC-NCL (PwD)",
    sc_pwd: "SC (PwD)",
    st_pwd: "ST (PwD)",
    ews_pwd: "EWS (PwD)"
  }

  defp seat_type_color(seat_type), do: Map.get(@seat_type_colors, seat_type, "text-stone-700 dark:text-zinc-300")
  defp seat_type_bg(seat_type), do: Map.get(@seat_type_bg, seat_type, "bg-stone-50 dark:bg-zinc-800/50")
  defp seat_type_label(seat_type), do: Map.get(@seat_type_labels, seat_type, "OPEN")

  def college_component2(assigns) do
    ~H"""
    <.card class="overflow-hidden gap-0! group hover:-translate-y-1 hover:shadow-lg transition-all duration-300">
      <:header class="!p-0 block!">
        <div class="relative h-32 sm:h-36 overflow-hidden">
          <img
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            src={"/#{@record.college.photo_path}"}
            alt={"#{@record.college.name} campus"}
            loading="lazy"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-black/10 to-transparent">
          </div>
          <div class="absolute bottom-2.5 left-3">
            <.badge
              variant="secondary"
              class="!bg-white/90 !text-stone-800 dark:!bg-zinc-900/90 dark:!text-zinc-200 backdrop-blur-sm"
            >
              {@record.college.class}
            </.badge>
          </div>
          <button
            id={"favorite-btn-#{@record.college.id}-#{@record.program.id}"}
            class="absolute top-2 right-2 p-1.5 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-sm rounded-full text-stone-400 hover:text-red-500 dark:hover:text-red-400 transition-colors"
            data-id={@record.college.id}
            data-program-id={@record.program.id}
            data-type="college_program"
            phx-hook="FavoriteButton"
            title="Add to favorites"
          >
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
              >
              </path>
            </svg>
          </button>
        </div>
      </:header>
      <:content>
        <div class="flex items-center gap-2 mb-2">
          <.badge variant="outline" class="text-[10px]">
            NIRF {nirf_helper(@record.rank)}
          </.badge>
        </div>

        <h3
          class="font-serif text-lg leading-tight text-stone-900 dark:text-zinc-100 group-hover:text-amber-700 dark:group-hover:text-amber-400 transition-colors mb-1"
          style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;"
          title={@record.college.name}
        >
          {@record.college.name}
        </h3>

        <p class="text-sm text-stone-500 dark:text-zinc-400 mb-3 flex items-center">
          <svg
            class="w-3 h-3 mr-1 flex-shrink-0"
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
          {@record.college.location}
        </p>

        <!-- Category label -->
        <%= if Map.has_key?(@record, :seat_type) do %>
          <div class="text-[10px] font-semibold uppercase tracking-wider mb-2">
            <span class={seat_type_color(@record.seat_type)}>
              {seat_type_label(@record.seat_type)} Cutoff
            </span>
          </div>
        <% end %>

        <!-- Rank Display -->
        <div class="grid grid-cols-2 gap-2">
          <div class={"text-center p-2.5 rounded-lg #{if Map.has_key?(@record, :seat_type), do: seat_type_bg(@record.seat_type), else: "bg-stone-50 dark:bg-zinc-800/50"}"}>
            <div class={"font-bold #{if Map.has_key?(@record, :seat_type), do: seat_type_color(@record.seat_type), else: ""}"}>
              <RankComponent.rank_display class="text-xl" rank={@record.opening_rank} />
            </div>
            <div class="text-[10px] text-stone-500 dark:text-zinc-400 uppercase tracking-wide">
              Opening
            </div>
          </div>
          <div class={"text-center p-2.5 rounded-lg #{if Map.has_key?(@record, :seat_type), do: seat_type_bg(@record.seat_type), else: "bg-stone-50 dark:bg-zinc-800/50"}"}>
            <div class={"font-bold #{if Map.has_key?(@record, :seat_type), do: seat_type_color(@record.seat_type), else: ""}"}>
              <RankComponent.rank_display class="text-xl" rank={@record.closing_rank} />
            </div>
            <div class="text-[10px] text-stone-500 dark:text-zinc-400 uppercase tracking-wide">
              Closing
            </div>
          </div>
        </div>
      </:content>
      <:footer class="flex flex-col gap-2">
        <.button
          navigate={~p"/colleges/#{@record.college}/programs/#{@record.program}"}
          class="w-full"
          size="sm"
        >
          View Cutoffs &rarr;
        </.button>
        <button
          type="button"
          id={"compare-btn-#{@record.college.id}-#{@record.program.id}"}
          phx-hook="CompareButtonHook"
          data-compare-college-id={@record.college.id}
          class="w-full inline-flex items-center justify-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-lg border transition-colors text-stone-600 dark:text-zinc-400 border-stone-200 dark:border-zinc-700 bg-transparent hover:bg-stone-100 dark:hover:bg-zinc-800"
        >
          <span class="compare-text">+ Compare</span>
        </button>
      </:footer>
    </.card>
    """
  end
end
