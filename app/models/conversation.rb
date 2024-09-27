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

  Segment = Struct.new(:diarized_part) do
    ASSISTANT = 'assistant'.freeze
    USER = 'user'.freeze

    def assistant? = role == ASSISTANT

    def user? = role == USER

    def role
      diarized_part['role']
    end

    def content
      if user?
        diarized_part.fetch('content').first['text']
      else
        diarized_part.fetch('content')
      end
    end
  end

  def segments
    @segments ||= exchange.map { |e| Segment.new(e) }
  end
end
