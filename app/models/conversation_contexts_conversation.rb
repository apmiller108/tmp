class ConversationContextsConversation < ApplicationRecord
  belongs_to :conversation
  belongs_to :conversation_context, dependent: :destroy
end
