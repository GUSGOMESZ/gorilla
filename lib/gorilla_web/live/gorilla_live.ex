defmodule GorillaWeb.GorillaLive do
  use GorillaWeb, :live_view

  def mount(_params, _session, socket) do
    today = DateTime.utc_now() |> DateTime.add(-3, :hour) |> DateTime.to_date()

    pull_up_reps = 10

    {:ok,
     socket
     |> assign(:today, today)
     |> assign(:pull_up_reps, pull_up_reps)
     |> assign_day(today)}
  end

  def render(assigns) do
    ~H"""
    <div id="pull-up-tracker" class="flex flex-col items-center gap-6 py-12">
        <h1 class="text-2xl font-semibold">Pull Ups</h1>
        <div class="flex flex-row items-center gap-4">
          <button
            phx-click="navigate"
            phx-value-direction="prev"
            class="flex size-9 items-center justify-center rounded-full text-base-content/70 hover:bg-base-200 hover:text-base-content transition-colors"
          >
            <.icon name="hero-chevron-left" class="size-5" />
          </button>
          <h2 class="w-40 text-center text-xl font-medium tabular-nums">{@date}</h2>
          <button
            disabled={@date == @today}
            phx-click="navigate"
            phx-value-direction="next"
            class={[
              "flex size-9 items-center justify-center rounded-full transition-colors",
              @date == @today && "text-base-content/30 cursor-not-allowed",
              @date != @today && "text-base-content/70 hover:bg-base-200 hover:text-base-content"
            ]}
          >
            <.icon name="hero-chevron-right" class="size-5" />
          </button>
        </div>

        <p class="text-6xl font-bold tabular-nums">{length(@done_sets) * @pull_up_reps}</p>

        <div class="grid grid-cols-5 gap-3">
          <button
            :for={i <- 1..10}
            id={"set-#{i}"}
            class={[
              "size-14 rounded-lg font-semibold border-2 transition-colors",
              i in @done_sets && "bg-primary text-primary-content border-primary",
              i not in @done_sets && "border-base-300 text-base-content/50"
            ]}
            phx-click="toggle"
            phx-value-set={i}
            phx-value-reps={@pull_up_reps}
          >
            {i}
          </button>
        </div>

        <div class="flex flex-col items-center gap-1 rounded-lg bg-base-200 px-6 py-3">
          <span class="text-xs font-medium uppercase tracking-wide text-base-content/60">
            Pull Ups
          </span>
          <span class="text-3xl font-bold tabular-nums">{@all_pull_ups}</span>
        </div>
      </div>
    """
  end

  def handle_event("toggle", %{"set" => set, "reps" => reps}, socket) do
    Gorilla.PullUp.toggle_set(socket.assigns.date, String.to_integer(set), String.to_integer(reps))
    {:noreply, assign_day(socket, socket.assigns.date)}
  end

  def handle_event("navigate", %{"direction" => direction}, socket) do
    new_date =
      case direction do
        "prev" -> Date.add(socket.assigns.date, -1)
        "next" -> Date.add(socket.assigns.date, 1)
      end

    {:noreply, assign_day(socket, new_date)}
  end

  defp assign_total_pull_ups(socket) do
    all_pull_ups = Gorilla.PullUp.list_all_time() |> Enum.map(& &1.reps) |> Enum.sum()

    socket
    |> assign(:all_pull_ups, all_pull_ups)
  end

  defp assign_day(socket, date) do
    done_sets = date |> Gorilla.PullUp.list_for_day() |> Enum.map(& &1.set)

    socket
    |> assign_total_pull_ups()
    |> assign(:date, date)
    |> assign(:done_sets, done_sets)
  end
end
