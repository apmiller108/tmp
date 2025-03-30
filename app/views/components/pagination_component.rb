# frozen_string_literal: true

class PaginationComponent < ApplicationViewComponent
  renders_one :container
  renders_one :list

  attr_reader :container_id, :cursor, :path, :pagination, :search_q

  # Produces infinite scroll lists. Works well with Paginate query object.
  # @param path [Array] contains method name and args for path helper to
  #   generate the path to the resource.
  # @param container_id [String] the DOM id of the element containing the items.
  #   Required when using the list slot.
  # @param cursor [Integer] The cursor for cursor based pagination. Used as query param.
  # @param pagination [Hash] the pagination options for traditional page/offset pagination.
  # @para search_q [Hash] any additional query params that should be
  # included in the request for the next page. Relevant for page/offset pagination.
  def initialize(path:, container_id: nil, cursor: nil, pagination: {}, search_q: {})
    @container_id = container_id
    @cursor = cursor
    @path = path
    @pagination = pagination
    @search_q = search_q
  end

  # Sends path helper method (eq, send(:user_memos_path, user, path_options))
  def collection_path
    send(*path, path_options)
  end

  def next_page_exists?
    pagination.fetch(:has_next_page, false)
  end

  private

  def path_options
    { format: :turbo_stream, q: search_q }.merge(cursor_params).merge(pagaination_params)
  end

  def cursor_params
    { c: (cursor if list) }.compact
  end

  def pagaination_params
    {
      page: next_page,
      per_page: pagination[:per_page]
    }.compact
  end

  def next_page
    return if pagination.blank?

    pagination.fetch(:current_page) + 1
  end
end
