FactoryBot.define do
  factory :conversation do
    title { Faker::Lorem.sentence }
    user
  end
end
