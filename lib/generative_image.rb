class GenerativeImage
  InvalidRequestError = Class.new(StandardError)

  def initialize(client = Stability::Client.new)
    @client = client
  end

  def text_to_image(prompts:, **opts)
    @client.text_to_image(prompts:, **opts)
  rescue Stability::ClientError
    raise InvalidRequestError
  end
end