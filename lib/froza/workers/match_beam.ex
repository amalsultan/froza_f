defmodule Froza.MatchBeam do
  @moduledoc """
  Worker to schedule the call to fetch matches data from Match beam api
  """
  use GenServer
  alias Froza.Matches
  alias Froza.Matches.Preprocess
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_state) do
    last_timestamp = Matches.get_last_data_fetch_timestamp("match_beam")
    schedule()
    {:ok, last_timestamp}
  end

  @doc """
   Calls helper method to get data from Match beam source.
   last_timestamp is used to get filter the new data which is not stored before.
   Data is also preprocessed after fetching to get the unified form to store in the database
  """
  def handle_info(:fetch_data, %{last_timestamp: last_timestamp}) do
    get_match_data()
    |> case do
      {:ok, %{"matches" => matches}} ->
        matches
        |> Preprocess.preprocess_data(last_timestamp)
        |> Matches.save_matches()
      {:error, error} -> {:error, error}
    end
    last_timestamp = Matches.get_last_data_fetch_timestamp("match_beam")
    schedule()
    {:noreply, last_timestamp}
  end

  #helper methods

  @doc """
   Get data from the match beam source.
   Getting api url from config file
  """
  @spec get_match_data :: nil
  def get_match_data() do
    Application.fetch_env!(:froza, :match_beam_end_point)
    |> HTTPoison.get!()
    |> case do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body
        |> Jason.decode()
      %HTTPoison.Response{status_code: 503} ->
        Logger.error("Failed to fetch Match Beam data as service is unavailable")
        {:error, :service_unavailable}
      _->
        Logger.error("Failed to fetch data")
        {:error, :failed}
    end
  end

  @doc """
   schedule a call to fetch data after every time interval which we are getting from config file
  """
  def schedule() do
    Process.send_after(self(), :fetch_data, Application.fetch_env!(:froza, :match_beam_delay))
  end
end
