FactoryBot.define do
  factory :generate_image_request do
    image_id { Faker::Alphanumeric.alpha(number: 20) }
    style { GenerativeImage::Stability::STYLE_PRESETS.sample }
    dimensions { GenerativeImage::Stability::DIMENSIONS.sample }
    user
  end
end
