defmodule CarrotWeb.PageLive.New do
  use CarrotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"collection_id" => collection_id}, _url, socket) do
    collection = Carrot.Repo.get!(Carrot.Collection, collection_id)

    socket =
      assign(socket,
        page_title: "New Page",
        live_action: :new,
        collection: collection,
        page: Ecto.build_assoc(collection, :pages)
      )

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      module={CarrotWeb.PageLive.FormComponent}
      id={:new}
      title={@page_title}
      action={@live_action}
      page={@page}
      patch={~p"/pages"}
    />

    <.back navigate={~p"/pages"}>Back to pages</.back>
    """
  end

  @impl Phoenix.LiveView
  def handle_info({CarrotWeb.PageLive.FormComponent, {:saved, page}}, socket) do
    {:noreply, stream_insert(socket, :pages, page)}
  end
end
