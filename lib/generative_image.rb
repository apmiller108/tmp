class GenerativeImage
  InvalidRequestError = Class.new(StandardError)

  # Quality levels are only relevent for text to image requests
  STANDARD_QUALITY = 'standard'.freeze
  HIGH_QUALITY = 'high'.freeze
  QUALITY_LEVELS = [STANDARD_QUALITY, HIGH_QUALITY].freeze
  DEFAULT_QUALITY_LEVEL = STANDARD_QUALITY

  def initialize(client = Stability::Client.new)
    @client = client
  end

  # @return [ImageResponse] responds to `image`
  def perform_request(generate_image_request)
    @client.perform_request(generate_image_request)
  rescue Stability::ClientError
    raise InvalidRequestError
  end
end
