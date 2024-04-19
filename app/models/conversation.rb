class Conversation < ApplicationRecord
  belongs_to :memo, optional: true

  attribute :exchange, default: []

  # TODO: custom validator exchange JSON schema
end
