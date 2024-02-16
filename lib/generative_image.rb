class GenerativeImage
  InvalidRequestError = Class.new(StandardError)

  def initialize(client = Stability::Client.new)
    @client = client
  end

  # @return [String] png file binary
  def text_to_image(prompts:, **opts)
    @client.text_to_image(prompts:, **opts)
  rescue Stability::ClientError
    raise InvalidRequestError
  end
end
