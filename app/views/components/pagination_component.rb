# frozen_string_literal: true

class PaginationComponent < ApplicationViewComponent
  renders_one :container
  renders_one :component

  attr_reader :container_id, :cursor, :path

  # @param path [Array] contains method name and args for path helper to
  #   generate the path to the resource.
  # @param container_id [String] the DOM id of the element containing the items.
  #   Required when using the component slot.
  # @param cursor [Integer] cursor for paginating the query. Used a query param.
  def initialize(path:, container_id: nil, cursor: nil)
    @container_id = container_id
    @cursor = cursor
    @path = path
  end

  def collection_path
    send(*path, path_options)
  end

  def pagination_turbo_frame
    turbo_frame_tag 'pagination', class: 'd-flex justify-content-center', src: collection_path, loading: :lazy do
      tag.div(class: 'spinner-border text-primary my-3', role: :status) do
        tag.span('Loading...', class: 'visually-hidden')
      end
    end
  end

  private

  def path_options
    { c: (cursor if component), format: :turbo_stream }.compact
  end
end
