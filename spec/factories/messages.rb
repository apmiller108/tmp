FactoryBot.define do
  factory :message do
    content { Faker::Lorem.sentence }
    trait :with_user do
      user
    end
  end
end
