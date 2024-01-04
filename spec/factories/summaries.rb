FactoryBot.define do
  factory :summary do
    content { Faker::Lorem.paragraph }
  end
end
