# frozen_string_literal: true

class GenerateTextPreset < ApplicationRecord
  has_one :generate_text_request, dependent: :nullify
  has_one :generate_text_presets_user, dependent: :destroy
  has_one :user, through: :generate_text_presets_user

  validates :name, :system_message, :temperature, presence: true

  enum :preset_type, {
    default: 'default',
    custom: 'custom'
  }
end
