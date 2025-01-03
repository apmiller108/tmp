class ConversationForm
  include ActiveModel::Model

  attr_accessor :assistant_response, :text_id, :user, :conversation, :title

  attr_reader :generate_text_request

  validates :assistant_response, presence: true, if: -> { generate_text_request.present? }
  validate :conversation_valid
  validate :generate_text_request_valid

  def initialize(params)
    super(params)
    @generate_text_request = user.generate_text_requests.find_by!(text_id:) if text_id
  end

  def save
    if generate_text_request
      conversation.exchange << Conversation::Turn.for_prompt(generate_text_request.prompt).turn_data
      generate_text_request.conversation = conversation
    end

    conversation.exchange << Conversation::Turn.for_response(assistant_response).turn_data if assistant_response

    conversation.title = title if title

    return false if invalid?

    save!
  end

  private

  def save!
    generate_text_request&.save!
    conversation.save!
  end

  def conversation_valid
    return if conversation.valid?

    conversation.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def generate_text_request_valid
    return if generate_text_request.nil? || generate_text_request.valid?

    generate_text_request.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
