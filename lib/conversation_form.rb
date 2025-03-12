class ConversationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend ActiveModel::Callbacks

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
  attribute :stream, :boolean, default: false

  validates :user, presence: true
  validate :valid_turnable, if: -> { turnable.present? }
  validate :valid_conversation

  define_model_callbacks :initialize, only: :after

  after_initialize :assign_default_values

  delegate :id, :persisted?, to: :conversation

  def initialize(attrs = {})
    run_callbacks :initialize do
      super
    end
  end

  # rubocop:disable Metrics/MethodLength
  def save
    conversation.assign_attributes(conversation_attributes)

    return false unless valid?

    conversation.save!

    if turnable.present?
      ActiveRecord::Base.transaction do
        turnable.save!
        turn.save!
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

  def turn
    @turn ||= conversation.turns.new(turnable:)
  end

  private

  def assign_default_values
    assign_default_title

    self.model                   ||= last_gen_text_opts.fetch(:model, user&.setting&.text_model)
    self.temperature             ||= last_gen_text_opts.fetch(:temperature, 0)
    self.generate_text_preset_id ||= last_gen_text_opts[:generate_text_preset_id]
  end

  def assign_default_title
    self.title ||= Conversation.title_from_prompt(prompt) if conversation.new_record?
  end

  def conversation_attributes
    {
      user:,
      updated_at: Time.current
    }.tap do |attrs|
      attrs[:title] = title if title.present?
      attrs[:memo_id] = memo_id if memo_id.present?
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

  def last_gen_text_opts
    @last_gen_text_opts ||= begin
      request = conversation.generate_text_requests.last
      return {} if request.nil?

      {
        model: request.model.api_name,
        **request.slice(:temperature, :generate_text_preset_id)
      }.symbolize_keys
    end
  end

  def enqueue_generate_job
    return if @turnable.nil?

    case turnable_type
    when 'GenerateTextRequest'
      GenerateTextJob.perform_async(turnable.id, stream)
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
