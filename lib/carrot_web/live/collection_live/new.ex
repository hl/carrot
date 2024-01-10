defmodule CarrotWeb.CollectionLive.New do
  use CarrotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "New Collection",
        live_action: :new,
        collection: %Carrot.Collection{}
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      module={CarrotWeb.CollectionLive.FormComponent}
      id={:new}
      title={@page_title}
      action={@live_action}
      collection={@collection}
      patch={~p"/collections"}
    />

    <.back navigate={~p"/collections"}>Back to collections</.back>
    """
  end

  @impl Phoenix.LiveView
  def handle_info({CarrotWeb.CollectionLive.FormComponent, {:saved, collection}}, socket) do
    {:noreply, stream_insert(socket, :collections, collection)}
  end
end
