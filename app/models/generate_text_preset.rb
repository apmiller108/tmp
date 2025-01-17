# frozen_string_literal: true

class GenerateTextPreset < ApplicationRecord
  has_one :generate_text_request, dependent: :nullify

  validates :name, :description, :system_message, :temperature, presence: true

  enum preset_type: {
    default: 'default',
    custom: 'custom'
  }
end
