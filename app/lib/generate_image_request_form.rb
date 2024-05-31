class GenerateImageRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :image_name, :string
  attribute :style, :string
  attribute :aspect_ratio, :string
  attribute :prompt, :string
  attribute :negative_prompt, :string
  attribute :user
  attribute :generate_image_request

  validate :prompts_must_have_text
  validate :generate_image_request_valid

  def initialize(attrs)
    super(attrs)
    self.generate_image_request = GenerateImageRequest.new(attrs.slice(:image_name, :style, :dimensions, :user))
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

  def generate_image_request_valid
    return if generate_image_request.valid?

    generate_image_request.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def prompts_must_have_text
    return if prompts&.all? { |p| p[:text].present? }

    errors.add(:prompts, "can't be blank")
  end
end
