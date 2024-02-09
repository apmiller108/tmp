class GenerateTextRequest
  belongs_to :user

  validates :text_id, :prompt, presence: true
end
