class GenerativeText
  InvalidRequestError = Class.new(StandardError)

  Model = Struct.new(:api_name, :name, :max_tokens, :vendor, keyword_init: true)

  MODELS = [
    *Anthropic::MODELS,
    *AWS::MODELS
  ]

  DEFAULT_MODEL = MODELS.find { _1.api_name == 'claude-3-5-haiku-latest' }

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
  end
end
