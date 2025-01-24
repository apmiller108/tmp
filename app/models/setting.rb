class Setting < ApplicationRecord
  attribute :text_model, default: GenerativeText::DEFAULT_MODEL.api_name

  belongs_to :user
end
