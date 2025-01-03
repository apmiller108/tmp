class Conversation < ApplicationRecord
  ASSISTANT = 'assistant'.freeze
  USER = 'user'.freeze

  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :generate_text_requests, dependent: :nullify

  validates :title, presence: true, length: { maximum: 100 }

  before_validation :set_title_from_prompt, on: :create

  attribute :exchange, default: []

  delegate :first, to: :exchange

  def turns
    @turns ||= exchange.map { |e| Turn.new(e) }
  end

  private

  def set_title_from_prompt
    self.title = turns.first.content.truncate(35) if title.blank?
  end
end
