# froza
To start your application

Install dependencies with mix deps.get

Create and migrate your database with mix ecto.setup

Start Server: mix run --no-halt

# Liberaries Used
      {:ecto_sql, "~> 3.2"},
      {:postgrex, "~> 0.15"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.0"}
      
# Overview

I created two workers by using Genserver which are supervised by supervisor. Both workers run independently to fetch Fast Ball data and Match Beam data. Each worker sends an api call to fetch data after every 30 seconds. The interval is configurable and can be changed from config file. Each worker gets data from api and proprocesses it to convert it into unified form so that it can be stored in a single table in database. 
