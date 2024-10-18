### Developer Guide for Setting Up Ruby on Rails with Dev Containers Using Colima

This guide will walk you through setting up a development environment for Ruby on Rails using Docker dev containers on a Mac, specifically using Colima, an alternative to Docker Desktop that works efficiently with macOS.

#### **Prerequisites**

1. **Homebrew**: Ensure you have Homebrew installed.&#x20;
2. **Colima**: Install Colima, which helps run Linux containers on macOS without needing Docker Desktop.
   ```bash
   brew install colima
   ```
3. **Docker CLI**: Install the Docker CLI to interact with Colima.
   ```bash
   brew install docker
   ```
4. \*\*Rails\*\*: Install Rails, to bootstrap a new project.
   ```
   brew install rails
   ```
5. **Create a Rails Application**: Before setting up the Docker environment, create a new Rails application using PostgreSQL and Tailwind CSS:
   ```bash
   rails new my_rails_app --database=postgresql --css=tailwind
   cd my_rails_app
   ```

#### **Using Multiple Dockerfiles**

The `rails new` command generates a Dockerfile designed for production use. This guide includes a separate Dockerfile for development purposes. It is recommended to keep both Dockerfiles, as they serve different environments:

- **Development Dockerfile**: This Dockerfile is tailored for development and supports volume mounting for real-time code editing.
- **Production Dockerfile**: The generated Dockerfile is optimized for deploying the Rails application in a production environment.

To keep things organized, place the development Dockerfile in the root directory (`my_rails_app`) and the production Dockerfile in a separate directory named `docker/production`.

#### **Setting Up Colima**

1. **Start Colima**: To start Colima with Docker, run:
   ```bash
   colima start
   ```
   You can configure Colima with additional settings like more CPU or memory if needed:
   ```bash
   colima start --cpu 2 --memory 4
   ```

#### **Creating a Rails Dev Container**

1. **Create a Development Dockerfile**: In your project directory (`my_rails_app`), create a `Dockerfile.dev` to define your Rails development environment:

   ```dockerfile
   FROM ruby:3.1

   # Install dependencies
   RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

   # Set up working directory
   WORKDIR /app

   # Install bundler
   RUN gem install bundler

   # Copy Gemfile and install gems
   COPY Gemfile .
   COPY Gemfile.lock .
   RUN bundle install --without production

   # Copy the rest of the application
   COPY . .

   # Expose port 3000 for Rails server
   EXPOSE 3000

   # Start the server by default
   CMD ["rails", "server", "-b", "0.0.0.0"]
   ```

2. **Create a ************************************************************************************************************************************************`docker-compose.yml`************************************************************************************************************************************************ File**: In the same project directory (`my_rails_app`), create a `docker-compose.yml` file to simplify container setup:

   ```yaml
   version: '3.9'
   services:
     web:
       build:
         context: .
         dockerfile: Dockerfile.dev
       ports:
         - "3000:3000"
       volumes:
         - .:/app
       depends_on:
         - db
     db:
       image: postgres:13
       environment:
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: password
   ```

3. **Build and Run the Containers**: Build and start your containers using Docker Compose:

   ```bash
   docker-compose run web bundle install && docker-compose up --build
   ```

   This command will build the Docker image for your Rails app and start both the web and database containers.

4. **Update the ************************************************************************************************************************************************`database.yml`************************************************************************************************************************************************ File**: Modify the `config/database.yml` file to match the PostgreSQL settings from your `docker-compose.yml`:

   ```yaml
   default: &default
     adapter: postgresql
     encoding: unicode
     pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
     host: db
     username: postgres
     password: password

   development:
     <<: *default
     database: my_rails_app_development
   ```

5. **Restart the Containers**: After updating the configuration, restart the containers:

   ```bash
   docker-compose up
   ```

6. **Confirm the Containers are running:** After running docker-compose up, ensure that the containers started correctly.

   ```
   docker ps
   ```

7. Create the Database: Once the containers are running, connect to the web container and create the database:

   ```
   docker-compose exec web /bin/bash
   bin/rails db:create
   ```

**Using Neovim for Development**

- You will be editing your project files using your code editor of choice **locally** while the Rails application runs inside the Docker container.
- **Mounting the Project Directory**: The `docker-compose.yml` file mounts your project directory (`.:/app`) so any changes you make in the editor will be reflected in the running container.

#### **Workflow**

1. **Start Colima**: Each time you begin working, start Colima:
   ```bash
   colima start
   ```
2. **Start the Containers**: Use Docker Compose to start your Rails and database containers:
   ```bash
   docker-compose up
   ```
3. **Access the App**: Your Rails app should be accessible at `http://localhost:3000`.

#### **Stopping the Environment**

- To stop the Rails server and database, press `Ctrl+C` in the terminal where `docker-compose up` is running.
- To stop Colima, run:
  ```bash
  colima stop
  ```


# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

