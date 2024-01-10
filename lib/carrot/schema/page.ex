defmodule Carrot.Page do
  @moduledoc """

  """

  use Carrot.Schema

  schema "pages" do
    field :path, :string
    field :template, :string

    embeds_many :fields, Field, on_replace: :delete do
      field :name, :string
      field :type, Ecto.Enum, values: [:text, :markdown]
      field :required, :boolean
      field :value, :string
    end

    belongs_to :collection, Carrot.Collection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:path, :template, :fields])
    |> update_change(:path, &Slug.slugify(&1, lowercase: false))
    |> cast_embed(:fields,
      with: &field_changeset/2,
      drop_param: :page_fields_drop,
      sort_param: :page_fields_sort
    )
    |> validate_required([:path])
    |> unique_constraint(:path)
    |> unsafe_validate_unique(:path, Carrot.Repo)
  end

  @doc false
  def field_changeset(field, attrs) do
    field
    |> cast(attrs, [:name, :type, :value, :required])
    |> validate_required([:name])
  end
end
