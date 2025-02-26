# frozen_string_literal: true

class ScrollspyComponent < ApplicationViewComponent
  renders_many :items

  attr_reader :container_id, :target_id, :action

  ITEMS_CONTAINER_ID = 'scrollspy-items'

  # @param container_id [String] DOM id of the scrollable container
  # @param target_id [String] DOM id of the nav list
  # @param action [String] Stimulus action that that can be used to invoke
  # scrollspy#refresh when new items are added to the scrollable container
  def initialize(container_id:, target_id:, action: '')
    @container_id = container_id
    @target_id = target_id
    @action = action
  end
end
