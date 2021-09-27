defmodule Froza.Matches.Match do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :home_team, :string
    field :away_team, :string
    field :provider, :string
    field :kickoff_at, :naive_datetime
    field :created_at, :naive_datetime
    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:home_team, :away_team, :provider, :kickoff_at, :created_at])
    |> validate_required([:home_team, :away_team, :provider, :kickoff_at, :created_at])
  end
end
