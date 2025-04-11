class Conversation < ApplicationRecord
  # excluding :embedding because it fill up the console with numbers
  self.attributes_for_inspect = %i[id title image_quality user_id memo_id create_at updated_at]

  # When getting the nearest neighbors, this attribute holds the distance if
  # included in the select statement. Example: given `vector` is Array<Float>,
  # Conversation.select("conversations.*, (embedding <=> '#{vector}') AS neighbor_distance")
  #             .where('embedding <=> ? < ?', vector.to_s, 0.7)
  attribute :neighbor_distance

  enum :image_quality,
       GenerativeImage::QUALITY_LEVELS.zip(GenerativeImage::QUALITY_LEVELS).to_h,
       default: GenerativeImage::DEFAULT_QUALITY_LEVEL

  scope :similar_to, ->(vector, threshold) {
    select("conversations.*, (embedding <=> '#{vector}') AS neighbor_distance")
      .where('embedding <=> ? < ?', vector.to_s, threshold)
  }

  belongs_to :memo, optional: true
  belongs_to :user, optional: false

  has_many :turns, -> { order created_at: :asc }, class_name: 'ConversationTurn', dependent: :destroy,
                                                  inverse_of: :conversation
  accepts_nested_attributes_for :turns
  has_many :generate_image_requests, through: :turns, source: :turnable, source_type: 'GenerateImageRequest'
  has_many :generate_text_requests, through: :turns, source: :turnable, source_type: 'GenerateTextRequest'

  validates :title, presence: true, length: { maximum: 100 }
  validates :image_quality, inclusion: {
    in: image_qualities.values, message: "%<value>s must be one of #{image_qualities.values}"
  }

  validate :memo_user_matches_conversation_user, if: :memo_id_changed?

  # @param [String] prompt
  def self.title_from_prompt(prompt)
    return Time.current.strftime('%a, %d %b %Y %H:%M:%S') if prompt.blank?

    prompt.truncate(40, separator: ' ')
  end

  def exchange
    generate_text_requests.completed.flat_map { _1.to_turn(turns: turns.to_a) }
  end

  def token_count
    generate_text_requests.sum(&:response_token_count)
  end

  # @return [String] a raw text version of the conversation including tool use
  # responses. Suitable for an embedding.
  def blobify
    [
      title,
      *generate_text_requests.completed.map(&:blobify)
    ].join(' ')
  end

  private

  def memo_user_matches_conversation_user
    return if memo_id.blank?

    memo_user_id = Memo.where(id: memo_id).pluck(:user_id)[0]

    return if user_id == memo_user_id

    errors.add(:memo_id, 'must belong to the same user as the conversation')
  end
end
