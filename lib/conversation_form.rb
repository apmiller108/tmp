class ConversationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :conversation, default: -> { Conversation.new }
  attribute :user
  attribute :title
  attribute :memo_id
  attribute :prompt
  attribute :text_id
  attribute :temperature
  attribute :generate_text_preset_id
  attribute :model
  attribute :file
  attribute :turnable_type

  validates :user, presence: true
  validate :valid_turnable, if: -> { turnable.present? }
  validate :valid_conversation

  def initialize(attrs = {})
    super
    conversation.assign_attributes(conversation_attributes)
  end

  # rubocop:disable Metrics/MethodLength
  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      conversation.save!
      if turnable.present?
        turnable.save!
        conversation.turns << turnable
      end
    end
    enqueue_generate_job
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
  # rubocop:enable Metrics/MethodLength

  def turnable
    return @turnable if defined? @turnable

    @turnable = case turnable_type
                when 'GenerateTextRequest'
                  GenerateTextRequest.new(generate_text_request_attributes)
                when 'GenerateImageRequest'
                  GenerateImageRequest.new(generate_image_request_attributes)
                end
  end

  private

  def conversation_attributes
    {
      user:,
      memo_id:
    }.tap do |attrs|
      attrs[:title] = default_title if conversation.new_record?
      attrs[:title] = title if title.present?
    end
  end

  def generate_text_request_attributes
    {
      prompt:,
      text_id:,
      temperature:,
      model:,
      file:,
      generate_text_preset_id:,
      user:
    }
  end

  def generate_image_request_attributes
    {}
  end

  def default_title
    if prompt
      Conversation.title_from_prompt(prompt)
    else
      Time.current.strftime('%a, %d %b %Y %H:%M:%S')
    end
  end

  def default_values
    {
      model: user.setting.text_model
    }
  end

  def enqueue_generate_job
    return if @turnable.nil?

    case turnable_type
    when 'GenerateTextRequest'
      GenerateTextJob.perform_async(turnable.id)
    end
  end

  def valid_turnable
    return if turnable.nil? || turnable.valid?

    turnable.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def valid_conversation
    return if conversation.valid?

    conversation.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
