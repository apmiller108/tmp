# frozen_string_literal: true

class PaginationComponent < ApplicationViewComponent
  renders_one :container
  renders_one :list

  attr_reader :container_id, :cursor, :path, :pagination

  # Produces infinite scroll lists. Works well with Paginate module functions.
  # @param path [Array] contains method name and args for path helper to
  #   generate the path to the resource.
  # @param container_id [String] the DOM id of the element containing the items.
  #   Required when using the list slot.
  # @param cursor [Integer] cursor for paginating the query. Used as query param.
  def initialize(path:, container_id: nil, cursor: nil, pagination: {})
    @container_id = container_id
    @cursor = cursor
    @path = path
    @pagination = pagination
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
    { format: :turbo_stream}.merge(cursor_params).merge(pagaination_params)
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
