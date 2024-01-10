defmodule Carrot.Repo do
  use Ecto.Repo,
    otp_app: :carrot,
    adapter: Ecto.Adapters.SQLite3

  require Ecto.Query

  @spec fetch_one(Ecto.Queryable.t(), Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch_one(queryable, opts \\ []) do
    case all(queryable, opts) do
      [record] -> {:ok, record}
      _none_or_multiple_records -> {:error, :not_found}
    end
  end

  @spec fetch(Ecto.Queryable.t(), term(), Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch(queryable, id, opts \\ []) do
    query =
      Ecto.Query.from(q in queryable,
        where: q.id == ^id
      )

    fetch_one(query, opts)
  end

  @spec fetch_by(Ecto.Queryable.t(), Keyword.t(), Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch_by(queryable, clauses, opts \\ []) do
    query =
      Enum.reduce(clauses, queryable, fn {k, v}, queryable ->
        Ecto.Query.from(q in queryable,
          where: field(q, ^k) == ^v
        )
      end)

    fetch_one(query, opts)
  end

  @spec transact(fun(), Keyword.t()) :: term()
  def transact(fun, opts \\ []) do
    transaction(
      fn repo ->
        result =
          case Function.info(fun, :arity) do
            {:arity, 0} -> fun.()
            {:arity, 1} -> fun.(repo)
          end

        case result do
          {:ok, result} -> result
          {:error, reason} -> repo.rollback(reason)
        end
      end,
      opts
    )
  end
end
