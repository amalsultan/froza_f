defmodule Froza.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Froza.Repo,
      # Starts Fast Ball worker by calling: Froza.FastBall.start_link(arg)
      %{id: Froza.FastBall,
       start: {Froza.FastBall, :start_link, [%{}]}},
      # Starts Match Beam worker by calling: Froza.MatchBeam.start_link(arg)
       %{id: Froza.MatchBeam,
       start: {Froza.MatchBeam, :start_link, [%{}]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Froza.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
