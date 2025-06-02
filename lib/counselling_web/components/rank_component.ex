defmodule CounsellingWeb.RankComponent do
  use Phoenix.Component

  def rank_display(assigns) do
    ~H"""
    <span
      class={"rank-badge px-2 py-1 #{@class}"}
      data-rank={@rank}
      phx-hook="RankDisplay"
      id={"rank-badge-#{@rank}-#{:crypto.strong_rand_bytes(4) |> Base.encode16()}"}
    >
      {@rank}
    </span>
    """
  end

  def rank_badge(%{rank: _} = assigns) do
    ~H"""
    <span
      class="rank-badge px-2 py-1 text-sm font-medium rounded-md bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200 transition-colors duration-200"
      data-rank={@rank}
      phx-hook="RankBadge"
      id={"rank-badge-#{@rank}-#{:crypto.strong_rand_bytes(4) |> Base.encode16()}"}
    >
      {@rank}
    </span>
    """
  end

  def rank_badge(rank) do
    assigns = %{rank: rank}

    ~H"""
    <span
      class="rank-badge px-2 py-1 text-sm font-medium rounded-md bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200 transition-colors duration-200"
      data-rank={@rank}
      phx-hook="RankBadge"
      id={"rank-badge-#{@rank}-#{:crypto.strong_rand_bytes(4) |> Base.encode16()}"}
    >
      {assigns.rank}
    </span>
    """
  end
end
