class Setting < ApplicationRecord
  attribute :text_model, default: GenerativeText::Anthropic::DEFAULT_MODEL.api_name

  belongs_to :user
end
