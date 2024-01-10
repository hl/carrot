defmodule CarrotWeb.PageLive.Index do
  use CarrotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"collection_id" => collection_id}, _url, socket) do
    collection = Carrot.Repo.get!(Carrot.Collection, collection_id)

    pages =
      collection
      |> Ecto.assoc(:pages)
      |> Carrot.Repo.all()

    socket =
      socket
      |> assign(collection: collection)
      |> stream(:pages, pages)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      Listing Pages
      <:actions>
        <.link patch={~p"/pages/new"}>
          <.button>New Page</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="pages"
      rows={@streams.pages}
      row_click={fn {_id, page} -> JS.navigate(~p"/pages/#{page}") end}
    >
      <:col :let={{_id, page}} label="Path"><%= page.path %></:col>
      <:action :let={{_id, page}}>
        <div class="sr-only">
          <.link navigate={~p"/pages/#{page}"}>Show</.link>
        </div>
        <.link patch={~p"/pages/#{page}"}>Edit</.link>
      </:action>
      <:action :let={{id, page}}>
        <.link
          phx-click={JS.push("delete", value: %{id: page.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end
end
