# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production use.
# Use with Kamal or build/run by hand:
#   docker build -t mr_wet_test .
#   docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name mr_wet_test mr_wet_test
#
# For a containerized development environment, see:
# https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Ensure the RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Set working directory for the Rails app.
WORKDIR /rails

# Install base packages. Adjust as needed for your app (e.g. libvips is used by image processing gems).
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# --- Build Stage ---
FROM base AS build

# Install build packages required for compiling gems, including libpq-dev for PostgreSQL.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy Gemfile and Gemfile.lock, then install gems.
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy the rest of the application code.
COPY . .

# Precompile bootsnap code for faster boot times.
RUN bundle exec bootsnap precompile app/ lib/

# Precompile Rails assets.
# We use a dummy secret key base since we don't need the real one during asset precompilation.
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# --- Final Stage ---
FROM base

# Copy installed gems and the built application from the build stage.
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create and switch to a non-root user for security.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint script to prepare the database (if needed).
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 80 and start the server.
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
