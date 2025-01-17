# frozen_string_literal: true

class GenerateTextPresetsUser < ApplicationRecord
  belongs_to :generate_text_preset, optional: false, inverse_of: :generate_text_presets_users, dependent: :destroy
  belongs_to :user, optional: false, inverse_of: :generate_text_presets_users
end
