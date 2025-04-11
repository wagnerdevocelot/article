# Use an official Ruby runtime as a parent image
FROM ruby:3.2-slim

# Set the working directory in the container
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
# We copy these first to leverage Docker cache
COPY Gemfile Gemfile.lock* ./

# Install dependencies
# Ensure Gemfile exists before running bundle install
# If Gemfile doesn't exist, this step might fail or do nothing.
# Consider creating a basic Gemfile first if needed.
RUN bundle install --jobs $(nproc) --retry 3

# Copy the rest of the application code
COPY . .

# Command to run the tests
CMD ["bundle", "exec", "rspec", "spec"] 