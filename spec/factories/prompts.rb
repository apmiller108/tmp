FactoryBot.define do
  factory :prompt do
    text { Faker::Lorem.sentence }
    weight { (-10..10).to_a.sample }
  end
end
