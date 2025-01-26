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

  def initialize(size: nil, centered: true, id: nil)
    @size = size
    @centered = centered
    @id = nil
  end

  def bs_size_class
    return '' if size.blank?

    "modal-#{size}"
  end

  def position_class
    @centered ? 'modal-dialog-centered' : ''
  end
end
