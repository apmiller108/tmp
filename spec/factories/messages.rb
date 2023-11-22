FactoryBot.define do
  factory :message do
    trait :with_user do
      user
    end
  end
end
