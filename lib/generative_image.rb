class GenerativeImage
  InvalidRequestError = Class.new(StandardError)

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
