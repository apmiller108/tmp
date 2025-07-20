# Pagination

This project uses a custom pagination implementation that supports both cursor-based and page/offset-based pagination. The `Paginate` module provides the pagination logic, and the `PaginationComponent` renders the pagination controls.

## Implementation Steps

To implement pagination for a resource, follow these steps:

1.  **Include the `Paginate` module in your controller.**
2.  **Use the `Paginate.cursor` or `Paginate.page` method in your controller's `index` action to paginate the records.**
3.  **Render the `PaginationComponent` in your `index.html.haml` view.**
4.  **Create an `index.html.turbo_stream.haml` view to handle the turbo stream response.**

## Cursor-Based Pagination

Cursor-based pagination is suitable for infinite scrolling and provides a more robust way to paginate large datasets without issues related to changing data during pagination.

### Example: Memos Pagination

Here's how cursor-based pagination is implemented for the `Memo` resource:

### 1. `MemosController`

The `MemosController` includes the `Paginate` module and uses the `Paginate.cursor` method in the `index` action:

```ruby
class MemosController < ApplicationController
  def index
    relation = current_user.memos.with_rich_text_content_and_embeds
    @memos, @cursor = Paginate.cursor(relation:, limit: 21, cursor: params[:c], order: { created_at: :desc })
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  # ...
end
```

### 2. `index.html.haml`

The `app/views/memos/index.html.haml` view renders the `PaginationComponent`:

```haml
.memos-index.mt-3{ data: { controller: 'memos', action: 'memo-card:memoConnected@window->memos#onMemoConnected' } }
  = turbo_stream_from current_user, TurboStreams::STREAMS[:memos]
  = render ModalComponent.new(size: :xl)
  .container
    %button.btn.btn-primary.mb-3{ data: { controller: 'modal-opener',
                                          modal: ModalComponent.id,
                                          'modal-src': new_user_memo_path(current_user) } }
      = t('memo.new')
  .container
    = render PaginationComponent.new(path: [:user_memos_path, current_user]) do |pagination|
      = pagination.with_container do
        #memos.grid.grid-auto-height
```

### 3. `index.html.turbo_stream.haml`

The `app/views/memos/index.html.turbo_stream.haml` view handles the turbo stream response:

```haml
= turbo_stream.append 'memos' do
  - @memos.each do |memo|
    = render MemoCardComponent.new(memo:)

= turbo_stream.replace 'pagination' do
  = render PaginationComponent.new(path: [:user_memos_path, current_user], cursor: @cursor)
```

This setup provides a seamless infinite scrolling experience for the user. When the user scrolls to the bottom of the page, a turbo stream request is made to the server, which returns the next page of results. The new results are then appended to the list, and the pagination controls are updated with the new cursor.

## Page/Offset Pagination

Page/offset pagination is a more traditional approach, suitable for scenarios where users might want to jump to specific pages or see a clear page count.

### Example: Conversations Pagination

Here's how page/offset pagination is implemented for the `Conversation` resource:

### 1. `ConversationsController`

The `ConversationsController` includes the `Paginate` module and uses the `Paginate.page` method in the `index` action. It also integrates with `ConversationSearch` for filtering and ordering.

```ruby
class ConversationsController < ApplicationController
  def index
    @search = ConversationSearch.new(relation: current_user.conversations, params: search_params[:q])
    @conversations, @pagination = Paginate.page(relation: @search.results,
                                                    page: params.fetch(:page, 0),
                                                    per_page: 15,
                                                    order: @search.order)

    request.variant = :lite if search_params[:variant] == 'lite'
    respond_to do |format|
      format.html
      format.turbo_stream
      format.json do
        render json: @conversations.as_json(only: %i[id created_at updated_at]), status: :ok
      end
    end
  end
  # ...
end
```

### 2. `index.html.haml`

The `app/views/conversations/index.html.haml` view renders the `PaginationComponent`, passing the `@pagination` object and `@search.params` to maintain search context across pages:

```haml
%turbo-frame.container{ id: :conversations_index }
  - if @search.applied_filters.include?(:semantic)
    .d-flex.justify-content-end.mb-2{ data: { controller: :tooltip }}
      %span.badge.bg-info.d-flex.align-items-center{
        data: { bs_toggle: "tooltip", bs_placement: "top" },
        title: "Showing search results for: "#{@search.search_term}""
      }
        %i.bi.bi-search.me-1
        Search results
        = link_to conversations_path, class: "ms-2 text-white", data: { turbo_frame: :conversations_index } do
          %i.bi.bi-x-circle
  = render PaginationComponent.new(path: [:conversations_path], pagination: @pagination, search_q: @search.params) do |pagination|
    = pagination.with_container do
      #conversations.list-group
```

### 3. `index.html.turbo_stream.haml`

The `app/views/conversations/index.html.turbo_stream.haml` view handles the turbo stream response by appending new conversations and updating the pagination component:

```haml
= turbo_stream.append 'conversations' do
  - @conversations.each do |conversation|
    = render ConversationComponent.new(conversation:)

= turbo_stream.replace 'pagination' do
  = render PaginationComponent.new(path: [:conversations_path], pagination: @pagination, search_q: @search.params)
```

This setup allows for traditional pagination with the added benefit of Turbo Streams for dynamic updates, ensuring a smooth user experience even with page-based navigation.