FactoryBot.define do
  factory :prompt do
    text { Faker::Lorem.sentence }
    weight { (-10..10).to_a.sample }

    trait :with_generate_image_request do
      generate_image_request
    end
  end
end
