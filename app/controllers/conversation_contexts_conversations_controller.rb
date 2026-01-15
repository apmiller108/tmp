class ConversationContextsConversationsController < ApplicationController
  before_action :set_conversation, only: [:create, :index, :destroy]
  before_action :set_available_contexts, only: [:index]

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    contexts = []
    conversation_contexts = []
    errors = []

    if conversation_context_params[:conversation_context_ids].present?
      contexts.concat(
        current_user.conversation_contexts
                    .where(id: conversation_context_params[:conversation_context_ids].compact)
                    .to_a
      )
    end

    if conversation_context_params[:file].present?
      model_api_name = current_user.setting&.text_model || GenerativeText::DEFAULT_MODEL.api_name
      model = GenerativeText::MODELS.find { |m| m.api_name == model_api_name }
      vendor = model&.vendor || :anthropic

      file_response = if vendor == :google
                        Gemini.upload_file(conversation_context_params[:file])
                      else
                        Anthropic.upload_file(conversation_context_params[:file])
                      end

      contexts << ConversationContext.create_for!(current_user, file_response, vendor:)
    end

    contexts.select(&:persisted?).each do |context|
      conversation_context = @conversation.conversation_contexts.create(context:)
      if conversation_context.persisted?
        conversation_contexts << conversation_context
      else
        errors << "Failed to add #{context.filename}"
      end
    end

    respond_to do |format|
      if conversation_contexts.any?
        streams = streams_for(conversation_contexts, errors)
        format.json { render turbo_stream: streams }
        format.turbo_stream { render turbo_stream: streams }
      else
        format.json { render json: context.errors, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now.alert = errors.present? ? errors.join(', ') : 'Unable to create context'
          flash_component = FlashMessageComponent.new(flash:)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def index
    @contexts = @conversation.conversation_contexts.order(created_at: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @contexts, status: :ok }
    end
  end

  def destroy
    @context = @conversation.conversation_contexts.find(params[:id])

    respond_to do |format|
      if @context.destroy
        @available_contexts = available_contexts
        format.turbo_stream
      else
        format.turbo_stream do
          flash.now.alert = 'Unable to delete conversation turn'
          flash_component = FlashMessageComponent.new(flash:)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def streams_for(conversation_contexts, errors)
    streams = []
    conversation_contexts.each do |conversation_context|
      streams << turbo_stream.prepend(
        'conversation-context-list',
        partial: 'conversation_contexts_conversations/conversation_context',
        locals: { conversation_context: }
      )
      streams << turbo_stream.remove(conversation_context.context)
    end
    if errors.any?
      flash.now.alert = errors.join(', ')
      flash_component = FlashMessageComponent.new(flash:)
      streams << turbo_stream.update(flash_component.id, flash_component)
    end
    streams
  end

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def set_available_contexts
    @available_contexts = available_contexts
  end

  def available_contexts
    current_user.conversation_contexts.available_for(@conversation).order(:filename)
  end

  def conversation_context_params
    params.require(:conversation_context).permit(:file, conversation_context_ids: [])
  end
end
