class GenerateImageRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :image_id, :string
  attribute :style, :string
  attribute :dimensions, :string
  attribute :prompts
  attribute :user
  attribute :generate_image_request

  validates :prompts, :image_id, :dimensions, presence: true
  validate :prompts_must_have_text

  def submit
    ActiveRecord::Base.transaction do
      self.generate_image_request = GenerateImageRequest.create!(image_id:, style:, dimensions:)
      prompts.each { |attrs| generate_image_request.prompts.create!(attrs) }
    end
  end

  private

  def prompts_must_have_text
    return if prompts.all? { |p| p['text'].present? }

    errors.add(:prompts, "can't be blank")
  end
end
