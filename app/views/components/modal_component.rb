# frozen_string_literal: true

class ModalComponent < ApplicationViewComponent
  renders_one :footer
  renders_one :title

  def self.id
    'tmp-modal'
  end

  def self.turbo_frame_body_id
    "#{id}-body"
  end

  attr_reader :size

  def initialize(size: nil)
    @size = size
  end

  def bs_size_class
    return '' if size.blank?

    "modal-#{size}"
  end
end
