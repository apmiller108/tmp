class GenerateImageRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :image_name, :string, default: -> { GenerateImageRequest.generate_name }
  attribute :style, :string
  attribute :aspect_ratio, :string
  attribute :prompt, :string
  attribute :negative_prompt, :string
  attribute :user
  attribute :generate_image_request

  validates :prompt, presence: true
  validate :generate_image_request_valid

  def initialize(attrs)
    super(attrs)
    self.generate_image_request = GenerateImageRequest.new(image_name:, style:, aspect_ratio:, user:)
  end

  def submit
    return false if invalid?

    ActiveRecord::Base.transaction do
      generate_image_request.save!
      prompts.each { |attrs| generate_image_request.prompts.create!(attrs) }
    end

    self
  end

  private

  def prompts
    [
      { text: prompt, weight: 1 },
      { text: negative_prompt, weight: -1 }
    ].select { |p| p[:text].present? }
  end

  def generate_image_request_valid
    return if generate_image_request.valid?

    generate_image_request.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
