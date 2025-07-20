# Pagination in this Project

This project implements a flexible pagination system using a custom `Paginate` module and a `PaginationComponent`. This system supports both cursor-based (for infinite scrolling) and page/offset-based pagination, and integrates seamlessly with Turbo Streams for dynamic updates.

## 1. The `Paginate` Module (`app/queries/paginate.rb`)

This module provides the core logic for fetching paginated data from ActiveRecord relations.

### `Paginate.cursor`

Used for cursor-based pagination, ideal for infinite scrolling where you fetch records relative to a given point (cursor).

```ruby
# @param relation [ActiveRecord::Relation] The base relation to paginate
# @param limit [Integer] Maximum number of records to return per request
# @param cursor [Integer, nil] The ID of the last record from the previous page. Nil for the first page.
# @param order [Hash] Sorting order, e.g., { created_at: :desc }
#
# @return [Array<Array, Integer, nil>] Returns an array containing:
#   - The fetched records (Array)
#   - The ID of the last record in the current set (which serves as the cursor for the next page), or nil if no more records.
#
# Example Usage in a Controller:
# @memos, @cursor = Paginate.cursor(relation: current_user.memos, limit: 21, cursor: params[:c], order: { created_at: :desc })
```

### `Paginate.paginate`

Used for traditional page/offset-based pagination, suitable when you need explicit page numbers or a fixed number of items per page.

```ruby
# @param relation [ActiveRecord::Relation] The base relation to paginate
# @param page [Integer] The current page number to retrieve (starts at 1). Defaults to 1.
# @param per_page [Integer] Number of records per page. Defaults to 10.
# @param order [Hash] Sorting order, e.g., { created_at: :desc }
#
# @return [Array<Array, Hash>] Returns an array containing:
#   - The fetched records (Array)
#   - A hash of pagination metadata (e.g., `:current_page`, `:per_page`, `:total_count`, `:has_next_page`).
#
# Example Usage in a Controller:
# @conversations, @pagination = Paginate.page(relation: @search.results,
#                                                    page: params.fetch(:page, 1),
#                                                    per_page: 15,
#                                                    order: @search.order)
```

## 2. The `PaginationComponent`

This ViewComponent is responsible for rendering the pagination controls and handling the infinite scroll behavior on the frontend.

```ruby
# @param path [Array] Contains the method name and arguments for the path helper
#   to generate the URL for the next page (e.g., `[:user_memos_path, current_user]`).
# @param container_id [String] The DOM ID of the element that will contain the paginated items.
# @param cursor [Integer] (Optional) The cursor value for cursor-based pagination.
# @param pagination [Hash] (Optional) The pagination metadata hash returned by `Paginate.page`.
# @param search_q [Hash] (Optional) Any additional query parameters (e.g., search terms) that should be
#   included in the request for the next page. This is crucial for preserving filters.
#
# Example Usage in a View:
# = render PaginationComponent.new(path: [:conversation_contexts_path], pagination: @pagination, search_q: @search_params[:q]) do |pagination|
#   = pagination.with_container do
#     #conversation_contexts.list-group.shadow-sm
#       # ... paginated items ...
```

## 3. Why Two `index` Templates (`.html.haml` and `.html.turbo_stream.haml`)

This project leverages Turbo Streams for a dynamic and efficient user experience, which necessitates two different `index` templates for paginated content:

*   **`index.html.haml` (HTML Format):**
    *   This template is rendered on the initial page load (e.g., when a user first navigates to `/conversation_contexts`).
    *   It renders the full HTML structure of the page, including the initial set of paginated items and the `PaginationComponent` itself.
    *   It sets up the `turbo-frame` that will be targeted by subsequent Turbo Stream updates.

*   **`index.html.turbo_stream.haml` (Turbo Stream Format):**
    *   This template is rendered for subsequent pagination requests (e.g., when the user scrolls to the bottom of the page, triggering an infinite scroll load).
    *   It *only* renders the new content that needs to be appended or replaced on the page, wrapped in `turbo_stream` actions.
    *   `turbo_stream.append 'container_id'` is used to add new items to the list.
    *   `turbo_stream.replace 'pagination_component_id'` is used to update the `PaginationComponent` (e.g., to pass the next page's cursor or pagination metadata).

This separation allows the initial page load to be a full HTML render for SEO and initial display, while subsequent loads are lightweight Turbo Stream responses that efficiently update only the necessary parts of the DOM without a full page refresh.

## 4. Using Query Parameters (e.g., `params[:q]`)

Query parameters are essential for filtering, searching, and maintaining state across pagination requests. In this project, search/filter parameters are often nested under a `q` key (e.g., `params[:q][:search]`).

### How it works:

1.  **Controller:**
    *   The controller's `index` action parses the `params` to extract search/filter criteria, often using a dedicated `search_params` method.
    *   These parameters are then used to filter the `relation` before passing it to `Paginate.page` or `Paginate.cursor`.
    *   The extracted search parameters are stored in an instance variable (e.g., `@search_params`) to be passed to the view.

2.  **View (`.html.haml`):**
    *   The search form uses `form_with url: ..., scope: :q` to ensure that input fields are nested under the `q` parameter (e.g., `q[search]`).
    *   The `PaginationComponent` receives these parameters via its `search_q` argument (e.g., `search_q: @search_params[:q]`). This ensures that when the `PaginationComponent` generates the URL for the next page, it includes the current search/filter parameters.

### Example: Conversation Contexts with Search

#### `app/controllers/conversation_contexts_controller.rb`

```ruby
class ConversationContextsController < ApplicationController
  # ... other actions ...

  def index
    @search_params = search_params
    relation = current_user.conversation_contexts.includes(:conversations)

    if search_params.dig(:q, :search).present?
      relation = relation.where(
        'filename ILIKE ? OR mime_type ILIKE ?',
        "%#{search_params[:q][:search]}%", "%#{search_params[:q][:search]}%"
      )
    end

    @conversation_contexts, @pagination = Paginate.page(relation: relation,
                                                        page: params.fetch(:page, 1),
                                                        per_page: 10,
                                                        order: { created_at: :desc })

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def search_params
    params.permit(:format, :page, :per_page, q: %i[search])
  end
end
```

#### `app/views/conversation_contexts/index.html.haml`

```haml
.container-fluid.mt-4
  .row.mb-3
    .col-md-8.offset-md-2
      = form_with url: conversation_contexts_path, method: :get, scope: :q, class: 'mb-3' do |form|
        .input-group
          = form.text_field :search, placeholder: 'Search conversation contexts...',
                           value: @search_params.dig(:q, :search), class: 'form-control'
          = form.submit 'Search', class: 'btn btn-outline-secondary'
          - if @search_params.dig(:q, :search).present?
            = link_to 'Clear', conversation_contexts_path, class: 'btn btn-outline-secondary'

  .row
    .col-md-8.offset-md-2
      = render PaginationComponent.new(path: [:conversation_contexts_path], pagination: @pagination, search_q: @search_params[:q]) do |pagination|
        = pagination.with_container do
          #conversation_contexts.list-group.shadow-sm
            - if @conversation_contexts.any?
              = render partial: 'conversation_context', collection: @conversation_contexts, as: :context
            - else
              .alert.alert-info.text-center
                %p.mb-0 No conversation contexts found.
```

#### `app/views/conversation_contexts/index.html.turbo_stream.haml`

```haml
= turbo_stream.append 'conversation_contexts' do
  - @conversation_contexts.each do |context|
    = render 'conversation_contexts/conversation_context', context: context

= turbo_stream.replace 'pagination' do
  = render PaginationComponent.new(path: [:conversation_contexts_path], pagination: @pagination, search_q: @search_params[:q])
```

This comprehensive example demonstrates how to implement page/offset pagination with search functionality, leveraging Turbo Streams for a dynamic user experience. The use of a dedicated partial for rendering individual items (`_conversation_context.html.haml`) keeps the main views clean and promotes reusability.
