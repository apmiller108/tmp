class Conversation < ApplicationRecord
  ASSISTANT = 'assistant'.freeze
  USER = 'user'.freeze

  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :generate_text_requests, dependent: :nullify

  validates :title, presence: true, length: { maximum: 100 }

  attribute :exchange, default: []

  delegate :first, to: :exchange

  def exchange
    turns.map(&:turn_data)
  end

  def turns
    generate_text_requests.order(:created_at).flat_map do |gtr|
      [
        Turn.for_prompt(gtr.prompt),
        Turn.for_response(gtr.response&.content) 
      ]
    end
  end

  private

  def set_title_from_prompt
    self.title = turns.first.content.truncate(35) if title.blank?
  end
end
