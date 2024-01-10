defmodule Carrot.Schema do
  @moduledoc """
  Schema helpers
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end
end
