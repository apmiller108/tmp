class ConversationContextsConversation < ApplicationRecord
  belongs_to :conversation
  belongs_to :context, dependent: :destroy, class_name: 'ConversationContext', foreign_key: 'conversation_context_id'
end
