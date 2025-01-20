# frozen_string_literal: true

class GenerateTextPreset < ApplicationRecord
  has_one :generate_text_request, dependent: :nullify
  has_one :generate_text_presets_user, dependent: :destroy
  has_one :user, through: :generate_text_presets_user

  validates :name, presence: true, length: { minimum: 3, maximum: 30 }
  validates :system_message, presence: true, length: { maximum: 500 }
  validates :temperature, presence: true, inclusion: { in: GenerateTextRequest::TEMPERATURE_VALUES }

  enum :preset_type, {
    default: 'default',
    custom: 'custom'
  }

  validates :preset_type, inclusion: { in: preset_types.values,
                                       message: "%<value>s must be one of #{preset_types.values}" }

  scope :for_user_options, ->(user_id) {
    left_joins(generate_text_presets_user: :user)
      .where(generate_text_presets_users: { users: { id: user_id } })
      .or(default)
      .order(:preset_type, :name)
  }
end
