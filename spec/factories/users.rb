FactoryBot.define do
  factory :user do
    email         { Faker::Internet.email }
    password      { Faker::Internet.password }

    trait :with_setting do
      setting
    end
  end
end
