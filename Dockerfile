FROM ruby:3.2.0

WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Use a shell form CMD to allow migrations to run before starting the server
CMD bash -c "bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0 -p 3000"
