FactoryBot.define do
  factory :generate_image_request do
    image_name { "genimage_#{Faker::Alphanumeric.alpha(number: 20)}" }
    style { GenerativeImage::Stability::STYLE_PRESETS.sample }
    aspect_ratio { GenerativeImage::Stability::CORE_ASPECT_RATIOS.sample }
    user
  end
end
