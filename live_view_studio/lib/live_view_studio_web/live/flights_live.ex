defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports
  alias LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        airport: "",
        flights: [],
        loading: false,
        matches: %{}
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="flights">
      <%!-- suggest airports and then search trips --%>
      <form phx-change="search">
        <input
          type="text"
          name="airport"
          value={@airport}
          placeholder="Airport Code"
          autofocus
          autocomplete="off"
          list="matches"
          phx-debounce="500"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <%!-- show suggestions --%>
      <%!-- <div>
        <%= inspect @matches %>
      </div> --%>
      <datalist id="matches">
        <option :for={{code, name} <- @matches} value={code}>
          <%= name %>
        </option>
      </datalist>

      <CustomComponents.loader loading={@loading} />

      <div class="flights">
        <ul>
            <li :for={flight <- @flights}>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <%= flight.origin %> to <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= flight.departure_time %>
                </div>
                <div class="arrives">
                  Arrives: <%= flight.arrival_time %>
                </div>
              </div>
            </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"airport" => airport}, socket) do
    send(self(), {:run_search, airport})

    socket =
      assign(socket,
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("suggest", %{"airport" => prefix}, socket) do
    {:noreply, assign(socket, matches: Airports.suggest(prefix))}
  end

  def handle_info({:run_search, airport}, socket) do
    socket =
      assign(socket,
        flights: Flights.search_by_airport(airport),
        loading: false
      )

    {:noreply, socket}
  end
end
