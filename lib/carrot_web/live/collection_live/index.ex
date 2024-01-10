defmodule CarrotWeb.CollectionLive.Index do
  use CarrotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    collections = Carrot.Repo.all(Carrot.Collection)
    socket = stream(socket, :collections, collections)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      Listing Collections
      <:actions>
        <.link patch={~p"/collections/new"}>
          <.button>New Collection</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="collections"
      rows={@streams.collections}
      row_click={fn {_id, collection} -> JS.navigate(~p"/collections/#{collection}") end}
    >
      <:col :let={{_id, collection}} label="Name"><%= collection.name %></:col>
      <:action :let={{_id, collection}}>
        <div class="sr-only">
          <.link navigate={~p"/collections/#{collection}"}>Show</.link>
        </div>
        <.link patch={~p"/collections/#{collection}"}>Edit</.link>
      </:action>
      <:action :let={{id, collection}}>
        <.link
          phx-click={JS.push("delete", value: %{id: collection.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    collection = Carrot.Repo.get!(Carrot.Collection, id)
    {:ok, _} = Carrot.Repo.delete(collection)

    {:noreply, stream_delete(socket, :collections, collection)}
  end
end
