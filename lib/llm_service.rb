class LLMService
  InvalidRequestError = Class.new(StandardError)

  attr_reader :client

  def initialize(client = AWS::Client.new)
    @client = client
  end

  def invoke_model_stream(prompt:, **opts, &block)
    client.invoke_model_stream(prompt:, **opts, &block)
  end
end
