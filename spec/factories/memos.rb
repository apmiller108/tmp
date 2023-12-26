FactoryBot.define do
  factory :memo do
    content { '<h1>Content</h1>' }

    trait :with_user do
      user
    end
  end
end
