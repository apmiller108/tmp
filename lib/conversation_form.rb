class ConversationForm
  include ActiveModel::Model

  attr_accessor :assistant_response, :text_id, :user, :memo_id

  attr_reader :conversation, :generate_text_request, :memo

  validates :assistant_response, presence: true
  validate :conversation_valid
  validate :generate_text_request_valid

  def initialize(params)
    super(params)
    @memo = user.memos.find(memo_id)
    @conversation = memo.conversation || memo.build_conversation(user:)
    @generate_text_request = user.generate_text_requests.find_by!(text_id:)
  end

  def save
    conversation.exchange << { role: :user, content: [{ type: :text, text: generate_text_request.prompt }] }
    conversation.exchange << { role: :assistant, content: assistant_response }
    generate_text_request.conversation = conversation

    return false if invalid?

    save!
  end

  private

  def save!
    conversation.save!
    generate_text_request.save!
  end

  def conversation_valid
    return if conversation.valid?

    conversation.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def generate_text_request_valid
    return if generate_text_request.valid?

    generate_text_request.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
