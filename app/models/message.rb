class Message < ApplicationRecord
  has_rich_text :content

  belongs_to :user, required: true, strict_loading: true
end
