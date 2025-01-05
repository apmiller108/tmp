class Conversation < ApplicationRecord
  ASSISTANT = 'assistant'.freeze
  USER = 'user'.freeze

  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :generate_text_requests, dependent: :nullify

  validates :title, presence: true, length: { maximum: 100 }

  validate :memo_user_matches_conversation_user, if: :memo_id_changed?

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

  def memo_user_matches_conversation_user
    return if memo_id.blank?

    memo_user_id = Memo.where(id: memo_id).pluck(:user_id)[0]

    return if user_id == memo_user_id

    errors.add(:memo_id, 'must belong to the same user as the conversation')
  end
end
