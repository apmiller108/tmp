# frozen_string_literal: true

class ModalComponent < ApplicationViewComponent
  renders_one :footer
  renders_one :title

  attr_reader :id, :size

  def initialize(id:, size: nil)
    @id = id
    @size = size
  end

  def bs_size_class
    return '' if size.blank?

    "modal-#{size}"
  end

  def body_turbo_frame_id
    "#{id}-body"
  end
end
