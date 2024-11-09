defmodule PhoneDb.Release do
  @moduledoc """
  Functions for managing released code
  """
  @app :phone_db

  require Logger

  alias Ecto.Adapters.SQL
  import Ecto.Query
  alias PhoneDb.Contacts.Contact
  alias PhoneDb.Repo

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    for r <- repos(), r == repo do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    end
  end

  def seconds_since_last_migration do
    Repo.one(
      from m in "schema_migrations",
        select: fragment("EXTRACT(EPOCH FROM age(NOW(), ?::timestamp))::BIGINT", m.inserted_at),
        order_by: [desc: m.inserted_at],
        limit: 1
    )
  end

  def migrations_check do
    repos = Application.fetch_env!(@app, :ecto_repos)

    migrations =
      repos
      |> Enum.map(&Ecto.Migrator.migrations/1)
      |> List.flatten()
      |> Enum.filter(fn
        {:up, _, _} -> false
        {_, _, _} -> true
      end)

    if Enum.empty?(migrations) do
      :ok
    else
      Logger.error("Migrations pending: #{inspect(migrations)}")
      {:error, "Migrations pending: #{inspect(migrations)}"}
    end
  end

  def database_check do
    repos = Application.fetch_env!(@app, :ecto_repos)

    Enum.reduce_while(repos, :ok, fn item, _acc ->
      case SQL.query(item, "SELECT 1") do
        {:ok, %{num_rows: 1, rows: [[1]]}} ->
          {:cont, :ok}

        {:error, reason} ->
          Logger.error("Database error: #{inspect(reason)}")
          {:halt, {:error, inspect(reason)}}
      end
    end)
  rescue
    e ->
      Logger.error("Database error: #{inspect(e)}")
      {:error, inspect(e)}
  end

  def ldap_check do
    contact = %Contact{phone_number: "000"}
    # This probably will fail because the contact doesn't exist.
    PhoneDb.Contacts.Ldap.get_contact(contact)
    :ok
  rescue
    e ->
      Logger.error("Database error: #{inspect(e)}")
      {:error, inspect(e)}
  end

  def health_check do
    with :ok <- database_check(),
         :ok <- ldap_check() do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp repos do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
