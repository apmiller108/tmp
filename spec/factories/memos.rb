FactoryBot.define do
  factory :memo do
    content { association :action_text_rich_text }
    trait :with_user do
      user
    end
  end
end
