class Conversation < ApplicationRecord
  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  attribute :exchange, default: []

  # TODO: custom validator exchange JSON schema
end
