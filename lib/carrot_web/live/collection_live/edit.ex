defmodule CarrotWeb.CollectionLive.Edit do
  use CarrotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _url, socket) do
    collection = Carrot.Repo.get!(Carrot.Collection, id)

    socket =
      assign(socket,
        collection: collection,
        page_title: "Edit Collection",
        live_action: :edit
      )

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      module={CarrotWeb.CollectionLive.FormComponent}
      id={@collection.id}
      title={@page_title}
      action={@live_action}
      collection={@collection}
      patch={~p"/collections"}
    />

    <.back navigate={~p"/collections"}>Back to collections</.back>
    """
  end

  @impl Phoenix.LiveView
  def handle_info({CarrotWeb.CollectionLive.FormComponent, {:saved, _collection}}, socket) do
    {:noreply, socket}
  end
end
