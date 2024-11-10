## Base stage ##
FROM elixir:1.17.3-alpine AS base

ARG ARG_APP_NAME=real_estate_auctions

# ENV are available during image build
# and when the container is running.
ENV APP_HOME=/$ARG_APP_NAME

WORKDIR $APP_HOME

RUN apk add --update git inotify-tools nodejs npm

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

## Development stage ##
FROM base AS dev
LABEL stage=development

COPY config/ $APP_HOME/config/
COPY mix.exs $APP_HOME/
COPY mix.* $APP_HOME/

RUN mix do deps.get, assets.setup, deps.compile

## Pre-Production stage ##
# FROM dev AS pre_prod

# COPY . $APP_HOME/

# RUN MIX_ENV=prod mix compile

# # Compile assets
# RUN MIX_ENV=prod mix assets.deploy

# # Put every ENV var required for build project here
# RUN MIX_ENV=prod mix release --path /prod_build

# RUN mix phx.gen.release

## Production stage ##
# FROM alpine AS prod

# ARG ARG_APP_NAME=currency_reader

# ENV APP_NAME=/$ARG_APP_NAME

# RUN apk add ncurses-libs libstdc++

# COPY --from=pre_prod /prod_build/ /elixir_prod_build

# EXPOSE 4000

# ENTRYPOINT /elixir_prod_build/bin/$APP_NAME start
