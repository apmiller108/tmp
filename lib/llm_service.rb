class LLMService
  InvalidRequestError = Class.new(StandardError)

  def self.summary_prompt_for(transcription:)
    Prompt.transcription_summary_prompt(transcription)
  end

  attr_reader :client

  def initialize(client = AWS::Client.new)
    @client = client
  end

  def invoke_model_stream(prompt:, **opts, &block)
    client.invoke_model_stream(prompt:, **opts, &block)
  end

  # @param prompt [String]
  # See InvokeModelRequest for available options
  # @return [InvokeModelResponse] the object containing the generated text.
  def invoke_model(prompt:, **opts)
    client.invoke_model(prompt:, **opts)
  rescue Aws::BedrockRuntime::Errors
    raise InvalidRequestError
  end
end
