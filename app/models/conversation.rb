class Conversation < ApplicationRecord
  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :generate_text_requests, -> { order(:created_at) }, dependent: :nullify

  validates :title, presence: true, length: { maximum: 100 }

  validate :memo_user_matches_conversation_user, if: :memo_id_changed?

  def exchange
    generate_text_requests.flat_map(&:to_turn)
  end

  def token_count
    generate_text_requests.reduce(0) { |sum, gtr| sum + gtr.response_token_count }
  end

  private

  def memo_user_matches_conversation_user
    return if memo_id.blank?

    memo_user_id = Memo.where(id: memo_id).pluck(:user_id)[0]

    return if user_id == memo_user_id

    errors.add(:memo_id, 'must belong to the same user as the conversation')
  end
end
