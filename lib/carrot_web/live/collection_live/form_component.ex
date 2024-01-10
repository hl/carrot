defmodule CarrotWeb.CollectionLive.FormComponent do
  @moduledoc """
  """

  use CarrotWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage collection records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="collection-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />

        <fieldset>
          <legend class="font-semibold leading-8 text-zinc-800">Fields</legend>

          <.inputs_for :let={collection_field} field={@form[:fields]}>
            <input
              type="hidden"
              name="collection[collection_fields_sort][]"
              value={collection_field.index}
            />
            <div class="grid gap-4 grid-cols-3">
              <div class="">
                <.input type="text" field={collection_field[:name]} label="Name" class="flex-1" />
              </div>
              <div class="">
                <.input
                  type="select"
                  field={collection_field[:type]}
                  options={Ecto.Enum.values(Carrot.Collection.Field, :type)}
                  label="Type"
                />
              </div>
              <div class="">
                <label>
                  <input
                    type="checkbox"
                    name="collection[collection_fields_drop][]"
                    value={collection_field.index}
                    class="hidden"
                    class="flex-1"
                  />
                  <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
                </label>
              </div>
            </div>
          </.inputs_for>

          <input type="hidden" name="collection[collection_fields_drop][]" />

          <label class="block cursor-pointer">
            <input type="checkbox" name="collection[collection_fields_sort][]" class="hidden" />
            add more
          </label>
        </fieldset>

        <:actions>
          <.button phx-disable-with="Saving...">Save Collection</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{collection: collection} = assigns, socket) do
    changeset = Carrot.Collection.changeset(collection, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"collection" => collection_params}, socket) do
    changeset =
      socket.assigns.collection
      |> Carrot.Collection.changeset(collection_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"collection" => collection_params}, socket) do
    save_collection(socket, socket.assigns.action, collection_params)
  end

  defp save_collection(socket, :edit, collection_params) do
    changeset = Carrot.Collection.changeset(socket.assigns.collection, collection_params)

    case Carrot.Repo.update(changeset) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_collection(socket, :new, collection_params) do
    changeset = Carrot.Collection.changeset(socket.assigns.collection, collection_params)

    case Carrot.Repo.insert(changeset) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection created successfully")
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
