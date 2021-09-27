defmodule Froza.Matches.Preprocess do
  @moduledoc """
  Preprocess the matches data coming from different sources to transform it into a unified form
  """
  def unix_to_naive_date_time(date_time) do
    date_time
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
  end

  @doc """
  preprocess data according to our data base structure of matches
  it also filters out the data which is already stored in database
  """
  @spec preprocess_data(any, any) :: any
  def preprocess_data(matches, last_timestamp) do
    matches
    |> Enum.filter(fn %{"created_at" => created_at} -> NaiveDateTime.diff(unix_to_naive_date_time(created_at), last_timestamp) > 0 end)
    |> Enum.reduce([], fn item, acc -> Enum.concat(acc, [get_unified_structure(item)])  end)
  end

  @doc """
    It runs for Fast Ball as fast ball sends teams data in home_team and away_team keys
  """
  def get_unified_structure(%{"created_at" => created_at, "kickoff_at" => kickoff_at, "home_team" => home_team, "away_team" => away_team}) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

      %{created_at: created_at |> DateTime.from_unix!() |> DateTime.to_naive(), home_team: home_team, away_team: away_team, kickoff_at: kickoff_at |> NaiveDateTime.from_iso8601!(), provider: "fast_ball", inserted_at: now, updated_at: now}
  end

  @doc """
    It runs for match beam as match beams sends teams data in teams field
  """
  def get_unified_structure(%{"created_at" => created_at, "kickoff_at" => kickoff_at, "teams" => teams}) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)
      [home_team, away_team] =
        teams
        |> String.split(" - ")
        |> Enum.map(fn item -> String.trim(item) end)

      %{created_at: created_at |> unix_to_naive_date_time() , home_team: home_team, away_team: away_team, kickoff_at: kickoff_at |> NaiveDateTime.from_iso8601!(), provider: "match_beam", inserted_at: now, updated_at: now}
  end
end
