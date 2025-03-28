# Dockerfile
FROM elixir:1.15.7

# Install dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  curl \
  npm \
  inotify-tools \
  libssl-dev \
  && rm -rf /var/lib/apt/lists/*

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

# Set working directory
WORKDIR /app

# Copy mix files and fetch deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get

# Copy the rest of the app
COPY . .

# Build assets
# RUN npm install --prefix assets && npm run deploy --prefix assets
# RUN mix phx.digest

# Compile and build release
RUN MIX_ENV=prod mix deps.compile && MIX_ENV=prod mix release

# Default command
CMD ["_build/prod/rel/realtime_silakes/bin/realtime_silakes", "start"]
