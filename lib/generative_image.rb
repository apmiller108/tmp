class GenerativeImage
  InvalidRequestError = Class.new(StandardError)

  def initialize(client = Stability::Client.new)
    @client = client
  end

  # @return [ImageResponse] responds to `image`
  # @option opts [String] :request_type
  # @option opts [String] :aspect_ratio
  # @option opts [String] :style_preset
  # @option opts [String] :seed
  # @option opts [String] :output_format png, webp, jpeg
  # @option opts [String] :image for image to image
  # @option opts [String] :strength denoise for image to image
  def perform_request(prompts:, **opts)
    @client.perform_request(prompts:, **opts)
  rescue Stability::ClientError
    raise InvalidRequestError
  end
end
