FactoryBot.define do
  factory :user do
    email         { Faker::Internet.email }
    password      { Faker::Internet.password }

    trait :with_setting do
      after :create do |user|
        create :setting, user:
      end
    end
  end
end
