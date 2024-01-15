# frozen_string_literal: true

class PaginationComponent < ApplicationViewComponent
  renders_one :container
  renders_one :list

  attr_reader :container_id, :cursor, :path

  # @param path [Array] contains method name and args for path helper to
  #   generate the path to the resource.
  # @param container_id [String] the DOM id of the element containing the items.
  #   Required when using the list slot.
  # @param cursor [Integer] cursor for paginating the query. Used a query param.
  def initialize(path:, container_id: nil, cursor: nil)
    @container_id = container_id
    @cursor = cursor
    @path = path
  end

  # Sends path helper method (eq, send(:user_memos_path, user, path_options))
  def collection_path
    send(*path, path_options)
  end

  private

  def path_options
    { c: (cursor if list), format: :turbo_stream }.compact
  end
end
