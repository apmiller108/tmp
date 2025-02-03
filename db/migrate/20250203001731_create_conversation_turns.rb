class CreateConversationTurns < ActiveRecord::Migration[7.2]
  def change
    create_view :conversation_turns
  end
end
