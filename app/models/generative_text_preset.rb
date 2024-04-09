class GenerativeTextPreset < ApplicationRecord
  validates :name, :description, :system_message, :temperature, presence: true
end
