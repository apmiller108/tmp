FactoryBot.define do
  factory :generate_text_request do
    text_id { Faker::Alphanumeric.alpha(number: 20) }
    prompt { Faker::Lorem.paragraph }
    user
  end
end
