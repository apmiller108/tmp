class Conversation < ApplicationRecord
  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :generate_text_requests, dependent: :nullify

  attribute :exchange, default: []

  delegate :first, to: :exchange

  # TODO: custom validator exchange JSON schema

  def starter
    return if first.nil?

    first.fetch('content').first.fetch('text')
  end
end
