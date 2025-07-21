# Gemini Project Information

This document provides information for the Gemini agent to effectively work on this project.

## Project Overview

This is a multi-modal AI chat application written in Ruby on Rails. It uses Anthropic for text generation, Stability AI for image generation, and AWS for other services like transcription. The front end is built with Hotwire and ViewComponent.

## Development Environment

The development environment is managed using Docker Compose.

### Services

The `docker-compose.yml` file orchestrates the following services:
- `database`: Postgres v16
- `redis`: Redis v7
- `ws`: Anycable WebSocket server
- `anycable`: Anycable gRPC server
- `app`: Ruby on Rails application
- `sidekiq`: Sidekiq background job process
- `chrome`: Browserless chrome for running feature/system tests.

### Getting Started

1.  **Build the Docker images:**
    ```bash
    docker compose build
    ```

2.  **Run the services:**
    ```bash
    docker compose up
    ```
    You can also run specific services, for example:
    ```bash
    docker compose up app
    ```

3.  **Access running containers:**
    - **App container:** `docker compose exec -it app bash`
    - **Database container:** `docker compose exec -it database psql -U postgres`

## Testing

The project uses RSpec for testing.

### Running Tests

- **Run all tests:**
  ```bash
  docker compose exec app bundle exec rspec
  ```

- **Run system tests:**
  1. Start the chrome service: `docker compose up -d chrome`
  2. Run the system specs: `docker compose exec app bundle exec rspec spec/system`

### Testing Notes

- **Authentication in tests:**
    - Request specs: Use Devise's `IntegrationHelpers`.
    - Feature/System specs: Use the `LoginHelper#login` helper.
    - JSON request specs: Use the `auth_headers` helper.
- **Turbo Streams:** Use the `have_turbo_stream` RSpec matcher.

### Testing Guidelines

- Do not write tests for active record model associations. These are typically covered by Rails itself.
- Before testing or interacting with an Active Record object, always inspect its model file and `db/schema.rb` to understand its attributes and associations. Do not assume attribute existence or type.

## Common Commands

- **Build docker images:** `docker compose build`
- **Start all services:** `docker compose up`
- **Stop all services:** `docker compose down`
- **Run tests:** `docker compose exec app bundle exec rspec`
- **Run Rubocop:** `docker compose exec app bundle exec rubocop`
- **Open a Rails console:** `docker compose exec app bundle exec rails c`
- **Open a shell in the app container:** `docker compose exec app bash`

## Key Technologies

- **Backend:** Ruby on Rails, Sidekiq, Anycable
- **Frontend:** Hotwire (Turbo, Stimulus), ViewComponent, Bootstrap
- **Database:** PostgreSQL, Redis
- **Testing:** RSpec, Capybara, Cuprite
- **Deployment:** Docker
