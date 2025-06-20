FactoryBot.define do
  factory :setting do
    text_model { GenerativeText::DEFAULT_MODEL.api_name }

    trait :with_anthropic_text_model do
      text_model { Anthropic.active_models.sample.api_name }
    end
  end
end
