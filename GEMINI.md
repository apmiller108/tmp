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
- **Navigation in system specs:** Use the `navigate_to` helper method instead of `visit`.

### Testing Guidelines

- Do not write tests for active record model associations. These are typically covered by Rails itself.
- Before testing or interacting with an Active Record object, always inspect its model file and `db/schema.rb` to understand its attributes and associations. Do not assume attribute existence or type.
- Use named subjects in RSpec tests.
- Ensure only one expectation per `it` block.

## Common Commands

- **Build docker images:** `docker compose build`
- **Start all services:** `docker compose up`
- **Stop all services:** `docker compose down`
- **Run tests:** `docker compose exec app bundle exec rspec`
- **Run Rubocop:** `docker compose exec app bundle exec rubocop`
- **Open a Rails console:** `docker compose exec app bundle exec rails c`
- **Open a shell in the app container:** `docker compose exec app bash`
- **Run Brakeman:** `docker run -v "$PWD":/code presidentbeef/brakeman`

## Architecture and Patterns

This project follows a modern Ruby on Rails architecture with a strong emphasis on componentization, background processing, and real-time features.

### Backend

- **Service Objects:** Business logic is encapsulated in service objects within the `lib/` directory (e.g., `TranscriptionService`, `GenerativeImage`). This keeps controllers thin and promotes reusability.
- **Query Objects:** Complex database queries are isolated in Query Objects located in the `app/queries` directory. This separates query logic from models and controllers.
- **Real-time with Anycable:** The application uses Anycable for handling WebSocket connections, providing a more performant alternative to the default Action Cable server. This is crucial for the real-time features of the chat application.
- **Authentication:** User authentication is handled by Devise, with support for both traditional session-based authentication and JWT for API requests. OmniAuth is used for third-party authentication (e.g., GitHub).
- **Dependency Injection:** The project uses `Dry::Effects` for dependency injection, as seen in the `ApplicationController` for providing the `current_user`.

### Frontend

- **Hotwire:** The frontend is built with Hotwire (Turbo and Stimulus), enabling a single-page application experience with server-rendered HTML.
- **ViewComponent:** UI elements are built as reusable ViewComponents, which are located in `app/views/components`. This promotes a modular and testable frontend architecture.
- **Component Previews:** ViewComponent previews are used for developing and testing components in isolation.

### Testing

- **RSpec:** The application is tested with RSpec, with a comprehensive suite of model, request, system, and component tests.
- **System Tests:** End-to-end testing is performed with Capybara and Cuprite, running in a headless Chrome container.
- **Test Helpers:** Custom test helpers are used to streamline testing, such as for authentication and mocking external services.

## Code Style

- **RuboCop:** The project uses RuboCop to enforce a consistent code style. The configuration is defined in the `.rubocop.yml` file.

## Key Technologies and Libraries

### Backend

- **Ruby on Rails:** A modern web application framework.
- **Sidekiq:** For background job processing.
- **Anycable:** For high-performance WebSocket communication.
- **Devise:** For user authentication.
- **Dry-rb:** A collection of libraries for writing robust and maintainable Ruby code.
- **ViewComponent:** For building reusable, testable UI components.

### Frontend

- **Hotwire (Turbo & Stimulus):** For building modern, responsive web applications with minimal JavaScript.
- **Bootstrap:** A popular CSS framework for building responsive, mobile-first sites.
- **esbuild:** A fast JavaScript bundler.

### Database

- **PostgreSQL:** A powerful, open-source object-relational database system.
- **pgvector:** A PostgreSQL extension for vector similarity search.
- **Redis:** An in-memory data structure store, used for caching and Sidekiq.

### Testing

- **RSpec:** A testing framework for Ruby.
- **Capybara:** An acceptance test framework for web applications.
- **Cuprite:** A headless Chrome driver for Capybara.

## New Features (pdf-support branch)

### File Context for Conversations

This branch introduces the ability to attach files to conversations, providing context to the LLM. Key components include:

- **`ConversationContext` Model:** Stores metadata about uploaded files (e.g., `file_ref`, `filename`, `mime_type`).
- **Anthropic Files API Integration:** Uses Anthropic's API for file uploads and management. This involves new `Anthropic::FilesClient` and `Anthropic::FileResponse` classes.
- **Background Jobs:**
    - `DeleteRemoteConversationContextJob`: Handles deletion of files from Anthropic.
- **UI for File Management:** A new modal allows users to upload new files or attach existing ones to a conversation. This is handled by `ConversationContextsController` and `ConversationContextsConversationsController`.
- **Prompt Augmentation:** The `Conversation#exchange` method is updated to include the content of attached files in the prompt sent to the LLM, enabling context-aware responses.
