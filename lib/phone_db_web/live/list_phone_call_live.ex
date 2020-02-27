defmodule PhoneDbWeb.ListPhoneCallLive do
  use Phoenix.LiveView

  import Phoenix.HTML.Link
  alias PhoneDb.Contacts

  alias PhoneDbWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <h1>Listing Phone Calls</h1>

    <form phx-change="search"><input type="text" name="query" value="<%= @query %>" placeholder="Search..." /></form>

    <table>
      <thead>
        <tr>
          <th phx-click="sort" phx-value-column="time">
            Time <%= sort_order_icon("time", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-column="phone_number">
            Phone Number <%= sort_order_icon("phone_number", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-column="name">
            Name <%= sort_order_icon("name", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-column="action">
            Action <%= sort_order_icon("action", @sort_by, @sort_order) %>
          </th>
          <th>
            Calls
          </th>
          <th>
          </th>
        </tr>
      </thead>
      <tbody>
        <%= for row <- @phone_calls do %>
          <tr>
            <td><%= format_timestamp(row.inserted_at) %></td>
            <td><%= row.contact.phone_number %></td>
            <td><%= row.contact.name %></td>
            <td>
                <%= Contacts.show_action row.action %>
                <%= if row.action != row.contact.action do %>
                    (<%= Contacts.show_action row.contact.action %>)
                <% end %>
            </td>
            <td><%= @stats[row.contact.id] %></td>
            <td>
              <%= link "Show", to: Routes.contact_path(@socket, :show, row.contact) %>
              <%= link "Edit", to: Routes.contact_path(@socket, :edit, row.contact) %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <nav class="float-left">
      <%= for page <- (1..number_of_pages(assigns)) do %>
        <%= if page == @page do %>
          <strong><%= page %></strong>
        <% else %>
          <a href="#" phx-click="goto-page" phx-value-page=<%= page %>><%= page %></a>
        <% end %>
      <% end %>
    </nav>
    <form phx-change="change-page-size" class="float-right">
      <select name="page_size">
        <%= for page_size <- [5, 10, 25, 50] do %>
          <option value="<%= page_size %>" <%= page_size == @page_size && "selected" || "" %>>
            <%= page_size %> per page
           </option>
        <% end %>
      </select>
    </form>
    """
  end

  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       query: session["query"],
       sort_by: "time",
       sort_order: :desc,
       page: 1,
       page_size: 10
     )
     |> load_data()}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, assign(socket, query: query, page: 1) |> load_data()}
  end

  # When the column that is used for sorting is clicked again, we reverse the sort order
  def handle_event(
        "sort",
        %{"column" => column},
        %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket
      )
      when column == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc) |> load_data()}
  end

  def handle_event(
        "sort",
        %{"column" => column},
        %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket
      )
      when column == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :asc) |> load_data()}
  end

  # A new column has been clicked
  def handle_event("sort", %{"column" => column}, socket) do
    {:noreply, assign(socket, sort_by: column) |> load_data()}
  end

  def handle_event("goto-page", %{"page" => page}, socket) do
    {:noreply, assign(socket, page: String.to_integer(page)) |> load_data()}
  end

  def handle_event("change-page-size", %{"page_size" => page_size}, socket) do
    {:noreply, assign(socket, page_size: String.to_integer(page_size), page: 1) |> load_data()}
  end

  defp rows(%{
         query: query,
         sort_by: sort_by,
         sort_order: sort_order,
         page: page,
         page_size: page_size
       }) do
    sort_by =
      case sort_by do
        "time" -> :inserted_at
        "name" -> :name
        "phone_number" -> :phone_number
        "action" -> :action
        _ -> :name
      end

    Contacts.list_phone_calls([{sort_order, sort_by}], query, page, page_size)
  end

  defp number_of_pages(%{query: query, page_size: page_size}) do
    number_of_rows = Contacts.count_phone_calls(query)
    (number_of_rows / page_size + 1) |> trunc
  end

  defp sort_order_icon(column, sort_by, :asc) when column == sort_by, do: "▲"
  defp sort_order_icon(column, sort_by, :desc) when column == sort_by, do: "▼"
  defp sort_order_icon(_, _, _), do: ""

  defp load_data(socket) do
    phone_calls = rows(socket.assigns)
    stats = Contacts.get_phone_call_stats_for_phone_calls(phone_calls)

    socket
    |> assign(:phone_calls, phone_calls)
    |> assign(:stats, stats)
    |> assign(:number_of_pages, number_of_pages(socket.assigns))
  end

  def format_timestamp(nil) do
    nil
  end

  def format_timestamp(timestamp) do
    timestamp
    |> shift_zone!("Australia/Melbourne")
    |> Calendar.Strftime.strftime!("%d/%m/%Y %H:%M")
  end

  defp shift_zone!(nil, _time_zone) do
    nil
  end

  defp shift_zone!(timestamp, time_zone) do
    timestamp
    |> Calendar.DateTime.shift_zone!(time_zone)
  end
end
