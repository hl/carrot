defmodule Carrot.Collection do
  @moduledoc """
  Content type that specifies the layout of a Page.
  """

  use Carrot.Schema

  schema "collections" do
    field :name, :string
    field :description, :string
    field :template, :string

    embeds_many :fields, Field, on_replace: :delete do
      field :name, :string
      field :type, Ecto.Enum, default: :text, values: [:text, :markdown]
      field :required, :boolean, default: false
    end

    has_many :pages, Carrot.Page

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:name, :description, :template, :fields])
    |> update_change(:name, &Slug.slugify(&1, lowercase: false))
    |> cast_embed(:fields,
      with: &field_changeset/2,
      drop_param: :collection_fields_drop,
      sort_param: :collection_fields_sort
    )
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> unsafe_validate_unique(:name, Carrot.Repo)
  end

  @doc false
  def field_changeset(field, attrs) do
    field
    |> cast(attrs, [:name, :type, :required])
    |> validate_required([:name])
  end
end
