defmodule Froza.Matches do
  alias Froza.Matches.Match
  alias Froza.Repo
  import Ecto.Query, warn: false
  require Logger

  def save_matches([]) do
    {:error, :no_data_provided}
  end

  def save_matches(matches) do
    count = Enum.count(matches)
    Logger.info("Trying to insert "<>inspect(count)<>" records in matches table")
    Match
    |> Repo.insert_all(matches)
    |> case do
      {count, _} ->
        Logger.info("Inserted "<>inspect(count)<>" records in matches table successfully")
        {:ok, :success}
      _-> Logger.info("Failed Insertion")
        {:ok, :success}
    end
  end

  def get_last_data_fetch_timestamp(provider) do
    query = from m in Match,
      select: %{last_timestamp: max(m.created_at)},
      where: m.provider == ^provider

    query
    |> Repo.one()
    |> case do
      %{last_timestamp: nil} ->
        %{last_timestamp: ~N[1970-09-26 17:36:40]}
      timestamp -> timestamp
    end
  end
end
