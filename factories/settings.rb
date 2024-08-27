FactoryBot.define do
  factory :setting do
    text_model { GenerativeText::Anthropic::MODELS.values.sample.api_name }
  end
end
