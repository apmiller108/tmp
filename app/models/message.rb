class Message < ApplicationRecord
  has_rich_text :content

  validates :content, presence: true

  belongs_to :user, required: true, strict_loading: true
end
