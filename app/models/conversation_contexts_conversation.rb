class ConversationContextsConversation < ApplicationRecord
  belongs_to :conversation
  belongs_to :context, class_name: 'ConversationContext', foreign_key: 'conversation_context_id',
                       inverse_of: :conversation_contexts_conversations
end
