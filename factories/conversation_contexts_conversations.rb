FactoryBot.define do
  factory :conversation_contexts_conversation do
    association :conversation
    association :context, factory: :conversation_context
  end
end
