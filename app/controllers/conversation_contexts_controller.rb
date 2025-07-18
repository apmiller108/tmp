class ConversationContextsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation_context, only: [:destroy]

  def index
    @conversation_contexts = current_user.conversation_contexts.includes(:conversations)

    if params[:search].present?
      @conversation_contexts = @conversation_contexts.where(
        'filename ILIKE ? OR mime_type ILIKE ?',
        "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end

    @conversation_contexts = @conversation_contexts.order(created_at: :desc)
  end

  def destroy
    @conversation_context.destroy
    respond_to do |format|
      if @conversation_context.destroyed?
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@conversation_context)
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_delete', model_name: 'Context')
          flash_component = FlashMessageComponent.new(flash:, record: @conversation_context)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_conversation_context
    @conversation_context = current_user.conversation_contexts.find(params[:id])
  end
end
