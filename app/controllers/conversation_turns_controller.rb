class ConversationTurnsController < ApplicationController
  before_action :set_conversation

  def destroy
    conversation_turn = @conversation.turns.find(params[:id])

    respond_to do |format|
      if conversation_turn.destroy
        format.turbo_stream do
          render turbo_stream: [
                   turbo_stream.remove(conversation_turn),
                   turbo_stream.remove(helpers.dom_id(conversation_turn, 'nav_item_'))
                 ]
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
end
