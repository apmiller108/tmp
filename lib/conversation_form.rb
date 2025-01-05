class ConversationForm
  include ActiveModel::Model

  attr_accessor :text_id, :user, :conversation, :title

  attr_reader :generate_text_request

  validate :conversation_valid
  validate :generate_text_request_valid

  def initialize(params)
    super(params)
    @generate_text_request = user.generate_text_requests.find_by!(text_id:) if text_id
  end

  def save
    # For new converstations a generate_text_request is created without a conversation ID
    # This ensures the association is made when the conversation is created
    if generate_text_request
      generate_text_request.conversation = conversation
    end

    conversation.title = generate_text_request.prompt.truncate(35) if conversation.title.blank?
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
