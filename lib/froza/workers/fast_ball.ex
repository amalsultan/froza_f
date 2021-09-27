defmodule Froza.FastBall do
  @moduledoc """
  Worker to schedule the call to fetch matches data from Fast Ball api
  """
  use GenServer
  alias Froza.Matches
  alias Froza.Matches.Preprocess
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_state) do
    last_timestamp = Matches.get_last_data_fetch_timestamp("fast_ball")
    schedule_call()
    {:ok, last_timestamp}
  end

  @doc """
   Calls helper method to get data from fast ball source.
   last_timestamp is used to get filter the new data which is not stored before.
   Data is also preprocessed after fetching to get the unified form to store in the database
  """
  def handle_info(:fetch_data, %{last_timestamp: last_timestamp}) do
    Logger.debug("getting fast ball matches data created after "<> inspect(last_timestamp))
    last_timestamp
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
    |> get_match_data()
    |> case do
      {:ok, %{"matches" => matches}} ->
        matches
        |> Preprocess.preprocess_data(last_timestamp)
        |> Matches.save_matches()
      {:error, error} -> {:error, error}
    end
    last_timestamp = Matches.get_last_data_fetch_timestamp("fast_ball")
    schedule_call()
    {:noreply, last_timestamp}
  end

  #helper methods
  @doc """
   Get data from the Fast Ball source.
   Getting api url from config file
  """
  def get_match_data(last_timestamp) do
    Application.fetch_env!(:froza, :fast_ball_end_point)
    |> HTTPoison.get!([], params: %{last_checked_at: last_timestamp})
    |> case do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body
        |> Jason.decode()
      %HTTPoison.Response{status_code: 503} ->
        Logger.error("Failed to fetch data as service is unavailable")
        {:error, :service_unavailable}
      %HTTPoison.Response{status_code: 400} ->
        Logger.error("Invalid query parameters are passed")
          {:error, :invalid_query_parameters}
      _->
        Logger.error("Failed to fetch data")
        {:error, :failed}
    end
  end

  @doc """
   schedule a call to fetch data after every time interval which we are getting from config file
  """
  def schedule_call() do
    Process.send_after(self(), :fetch_data, Application.fetch_env!(:froza, :fast_ball_delay))
  end
end
