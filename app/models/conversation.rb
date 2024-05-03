class Conversation < ApplicationRecord
  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :generate_text_requests, dependent: :nullify

  attribute :exchange, default: []

  # TODO: custom validator exchange JSON schema
end
