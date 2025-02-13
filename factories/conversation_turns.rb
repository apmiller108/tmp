FactoryBot.define do
  factory :conversation_turn do
    conversation

    trait :for_text do
      association :turnable, factory: :generate_text_request
    end

    trait :for_image do
      association :turnable, factory: :generate_text_request
    end
  end
end
