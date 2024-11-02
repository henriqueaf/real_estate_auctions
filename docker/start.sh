#!/usr/bin/env sh

echo "Installing dependencies ================================="
mix deps.get

# echo "Creating Database ======================================="
# mix ecto.create

# echo "Migrating Database ======================================"
# mix ecto.migrate

# echo "Starting application inside IEx ==============="
# iex -S mix phx.server

echo "Starting mix server ==============="
mix phx.server
