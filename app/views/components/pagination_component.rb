# frozen_string_literal: true

class PaginationComponent < ApplicationViewComponent
  renders_one :container
  renders_one :component

  attr_reader :container_id, :pagy, :path

  # @param path [Array] contains method name and args for path helper to
  #   generate the path to the resource.
  # @param container_id [String] the DOM id of the element containing the items.
  #   Required when using the component slot.
  # @param pagy [Pagy] pagy pagination library (obj that responds to `next`).
  #   Required when using the component slot.
  def initialize(path:, container_id: nil, pagy: nil)
    @container_id = container_id
    @pagy = pagy
    @path = path
  end

  def collection_path
    send(*path, path_options)
  end

  def pagination_turbo_frame
    turbo_frame_tag 'pagination', src: collection_path, loading: :lazy
  end

  private

  def path_options
    { page: (pagy&.next if component), format: :turbo_stream }.compact
  end
end
