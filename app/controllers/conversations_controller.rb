class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[edit update destroy]

  def index
    @conversations = current_user.conversations.order(created_at: :desc)
  end

  def new
    @conversation = current_user.conversations.new
  end

  def edit; end

  def update
    respond_to do |format|
      format.turbo_stream do
        if @conversation.update(conversation_params)
          render 'conversations/update', locals: { conversation: @conversation }, status: :ok
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:, record: @conversation)

          render turbo_stream: [
                   turbo_stream.update(flash_component.id, flash_component),
                   turbo_stream.remove(ConversationTurnComponent::PENDING_RESPONSE_DOM_ID)
                 ],
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @conversation.destroy
    respond_to do |format|
      format.turbo_stream do
        redirect_to user_conversations_path(current_user), status: :see_other, notice: 'Conversation was deleted'
      end
      format.html { redirect_to user_conversations_path(current_user) }
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:title)
  end
end
