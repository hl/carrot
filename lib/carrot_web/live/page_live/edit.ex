defmodule CarrotWeb.PageLive.Edit do
  use CarrotWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id, "collection_id" => collection_id}, _url, socket) do
    collection = Carrot.Repo.get!(Carrot.Collection, collection_id)

    page =
      collection
      |> Ecto.assoc(:pages)
      |> Carrot.Repo.get!(id)

    socket =
      assign(socket,
        collection: collection,
        page: page,
        page_title: "Edit Page",
        live_action: :edit
      )

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      module={CarrotWeb.PageLive.FormComponent}
      id={@page.id}
      title={@page_title}
      action={@live_action}
      page={@page}
      patch={~p"/pages"}
    />

    <.back navigate={~p"/pages"}>Back to pages</.back>
    """
  end

  @impl Phoenix.LiveView
  def handle_info({CarrotWeb.PageLive.FormComponent, {:saved, _page}}, socket) do
    {:noreply, socket}
  end
end
