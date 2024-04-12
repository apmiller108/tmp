FactoryBot.define do
  factory :generate_text_request do
    text_id { Faker::Alphanumeric.alpha(number: 20) }
    prompt { Faker::Lorem.paragraph }
    temperature { 0.step(to: 1, by: 0.1).to_a.sample }
    user

    trait :with_generate_text_preset do
      generate_text_preset
    end
  end
end
