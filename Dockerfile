FROM ruby:3.3

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set up working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without production

# Copy the rest of the application
COPY . ./

# Expose port 3000 for Rails server
EXPOSE 3000

# Start the server by default
CMD ["rails", "server", "-b", "0.0.0.0"]
