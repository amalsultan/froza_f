import Config

config :froza, ecto_repos: [Froza.Repo]
config :froza, Froza.Repo,
  database: "froza_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

#Api endpoint and worker configuration
config :froza,
  match_beam_end_point: "http://forzaassignment.forzafootball.com:8080/feed/matchbeam",
  match_beam_delay: 30000,
  fast_ball_end_point: "http://forzaassignment.forzafootball.com:8080/feed/fastball",
  fast_ball_delay: 30000
