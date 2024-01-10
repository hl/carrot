defmodule Carrot.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :name, :text, null: false
      add :description, :text
      add :template, :text
      add :fields, :map

      timestamps()
    end

    create unique_index(:collections, [:name])

    create table(:pages) do
      add :path, :text, null: false
      add :template, :text
      add :fields, :map
      add :collection_id, references(:collections)

      timestamps()
    end

    create unique_index(:pages, [:path])
  end
end
