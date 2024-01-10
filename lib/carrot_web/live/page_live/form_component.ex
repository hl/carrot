defmodule CarrotWeb.PageLive.FormComponent do
  @moduledoc """
  """

  use CarrotWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage page records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="page-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:path]} type="text" label="Path" />

        <fieldset>
          <legend class="font-semibold leading-8 text-zinc-800">Fields</legend>

          <.inputs_for :let={page_field} field={@form[:fields]}>
            <input type="hidden" name="page[page_fields_sort][]" value={page_field.index} />
            <div class="grid gap-4 grid-cols-3">
              <div class="">
                <.input type="text" field={page_field[:name]} label="Name" class="flex-1" />
              </div>
              <div class="">
                <.input
                  type="select"
                  field={page_field[:type]}
                  options={Ecto.Enum.values(Carrot.Page.Field, :type)}
                  label="Type"
                />
              </div>
              <div class="">
                <label>
                  <input
                    type="checkbox"
                    name="page[page_fields_drop][]"
                    value={page_field.index}
                    class="hidden"
                    class="flex-1"
                  />
                  <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
                </label>
              </div>
            </div>
          </.inputs_for>

          <input type="hidden" name="page[page_fields_drop][]" />

          <label class="block cursor-pointer">
            <input type="checkbox" name="page[page_fields_sort][]" class="hidden" /> add more
          </label>
        </fieldset>

        <:actions>
          <.button phx-disable-with="Saving...">Save Page</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{page: page} = assigns, socket) do
    changeset = Carrot.Page.changeset(page, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    changeset =
      socket.assigns.page
      |> Carrot.Page.changeset(page_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    save_page(socket, socket.assigns.action, page_params)
  end

  defp save_page(socket, :edit, page_params) do
    changeset = Carrot.Page.changeset(socket.assigns.page, page_params)

    case Carrot.Repo.update(changeset) do
      {:ok, page} ->
        notify_parent({:saved, page})

        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_page(socket, :new, page_params) do
    changeset = Carrot.Page.changeset(socket.assigns.page, page_params)

    case Carrot.Repo.insert(changeset) do
      {:ok, page} ->
        notify_parent({:saved, page})

        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
