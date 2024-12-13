class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[edit update destroy]

  def index
    @conversations = current_user.conversations.order(created_at: :desc)
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
    form = ConversationForm.new(form_params)

    respond_to do |format|
      format.turbo_stream do
        if form.save
          render(
            turbo_stream: [
              turbo_stream.append(
                'conversation-turns',
                ConversationTurnComponent.new(assistant_response_to_turn).render_in(view_context)
              ),
              turbo_stream.replace(
                'prompt-form',
                PromptFormComponent.new(conversation: @conversation).render_in(view_context)
              )
            ],
            status: :ok
          )
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
  end

  private

  def assistant_response_to_turn
    Conversation::Turn.for_prompt(conversation_params[:assistant_response])
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
