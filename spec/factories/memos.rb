FactoryBot.define do
  factory :memo do
    content { Faker::Lorem.sentence }
    trait :with_user do
      user
    end
  end
end
