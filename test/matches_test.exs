defmodule Froza.MatchesTest do
  use ExUnit.Case
  doctest Froza

  alias Froza.Matches.Preprocess

  describe "matches" do
    alias Froza.Matches.Match

    @valid_last_timestamp ~N[2021-09-26 17:36:40]
    @valid_match_beam_data [%{"teams"=> "Arsenal - Chelsea FC", "kickoff_at"=> "2021-10-11T17:00:00Z", "created_at"=> 1632764415}]
    @valid_fast_ball_data [%{"home_team"=> "Arsenal", "away_team"=> "Chelsea FC", "kickoff_at"=> "2021-10-11T17:00:00Z", "created_at"=> 1632764415}]
    @invalid_attrs [%{
      "teams": nil,
      "kickoff_at": nil,
      "created_at": nil
    }]

    def preprocess_match_data(last_time_stamp, data \\ []) do
        data
        |> Preprocess.preprocess_data(last_time_stamp)
    end

    test "preprocess_data/2 with valid match beam data " do
      assert [
        %{
          away_team: "Chelsea FC",
          created_at: ~N[2021-09-27 17:40:15],
          home_team: "Arsenal",
          kickoff_at: ~N[2021-10-11 17:00:00],
          provider: "match_beam",
        }
      ] = preprocess_match_data(@valid_last_timestamp, @valid_match_beam_data)
    end

    test "preprocess_data/2 with valid fast ball data " do
      assert [
        %{
          away_team: "Chelsea FC",
          created_at: ~N[2021-09-27 17:40:15],
          home_team: "Arsenal",
          kickoff_at: ~N[2021-10-11 17:00:00],
          provider: "fast_ball",
        }
      ] = preprocess_match_data(@valid_last_timestamp, @valid_fast_ball_data)
    end
  end
end
