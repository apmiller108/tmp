class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[edit update destroy]

  def index
    @conversations = current_user.conversations.order(created_at: :desc)
  end

  def new
    @conversation = current_user.conversations.new
  end

  def create
    @conversation = current_user.conversations.new
    form = ConversationForm.new(form_params)

    if form.save
      response.headers['Content-Type'] = 'text/html'
      redirect_to edit_user_conversation_path(current_user, @conversation)
    else
      flash.now.alert = t('unable_to_generate_text')
      flash_component = FlashMessageComponent.new(flash:, record: form)

      render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
             status: :unprocessable_entity
    end
  end

  def edit
    render template: 'conversations/edit', formats: %i[html]
  end

  def update
    form = ConversationForm.new(form_params)

    respond_to do |format|
      format.turbo_stream do
        if form.save
          render(
            turbo_stream: [
              turbo_stream.replace(
                ConversationTurnComponent::PENDING_RESPONSE_DOM_ID,
                ConversationTurnComponent.new(assistant_response_to_turn).render_in(view_context)
              )
            ],
            status: :ok
          )
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:, record: form)

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
        redirect_to user_conversations_path(current_user), status: :see_other, notice: 'Memo was deleted'
      end
      format.html { redirect_to user_conversations_path(current_user) }
    end
  end

  private

  def assistant_response_to_turn
    Conversation::Turn.for_response(conversation_params[:assistant_response])
  end

  def form_params
    conversation_params.merge(user: current_user, conversation: @conversation)
  end

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:assistant_response, :text_id)
  end
end
