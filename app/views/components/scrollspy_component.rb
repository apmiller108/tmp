# frozen_string_literal: true

class ScrollspyComponent < ApplicationViewComponent
  renders_many :items

  attr_reader :container_id, :target_id

  def initialize(container_id:, target_id:)
    @container_id = container_id
    @target_id = target_id
  end
end
