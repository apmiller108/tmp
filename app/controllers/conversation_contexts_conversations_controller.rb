class ConversationContextsConversationsController < ApplicationController
  before_action :set_conversation, only: [:create, :index, :destroy]
  before_action :set_available_contexts, only: [:index]

  def create
    context = if conversation_context_params[:conversation_context_id].present?
                ConversationContext.find(params[:conversation_context_id])
              elsif conversation_context_params[:file].present?
                file_response = Anthropic.upload_file(conversation_context_params[:file])
                ConversationContext.create_for!(current_user, file_response)
              end

    conversation_context = @conversation.conversation_contexts.create(context:)

    respond_to do |format|
      if conversation_context.persisted?
        format.json do
          render turbo_stream: turbo_stream.prepend(
            'conversation-context-list',
            partial: 'conversation_contexts_conversations/conversation_context',
            locals: { conversation_context: }
          )
        end
      else
        format.json { render json: context.errors, status: :unprocessable_entity }
      end
    end
  rescue ConversationContext::CreateError
    DeleteRemoteConversationContextJob.perform_async(file_response.id)
  end

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
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@context)
        end
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

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def set_available_contexts
    @available_contexts = current_user.conversation_contexts
                                      .where('id NOT IN (:ids)',
                                             ids: ConversationContext.select(:id)
                                                                     .joins(conversation_contexts_conversations: :conversation)
                                                                     .where(conversation: { id: @conversation.id }))
                                      .order(:filename)
  end

  def conversation_context_params
    params.require(:conversation_context).permit(:file, :conversation_context_id)
  end
end
