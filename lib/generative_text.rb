class GenerativeText
  InvalidRequestError = Class.new(StandardError)

  Model = Struct.new('Model', :api_name, :name, :max_tokens, :vendor, :capabilities, keyword_init: true)
  Model::Capabilities = Struct.new('ModelCapabilities', :image?)

  MODELS = [
    *Anthropic::MODELS,
    *AWS::MODELS
  ].freeze

  DEFAULT_MODEL = MODELS.find { _1.api_name == 'claude-3-5-haiku-latest' }

  def self.summary_prompt_for(transcription:)
    Helpers.transcription_summary_prompt(transcription)
  end

  def self.client_for(generate_text_request)
    case generate_text_request.model.vendor
    when :aws
      AWS::Client
    when :anthropic
      Anthropic::Client
    end
  end

  # @param [GenerateTextRequest] request object
  # The block is what should yield to each stream chunk
  def invoke_model_stream(generate_text_request, **opts, &block)
    client = self.class.client_for(generate_text_request).new
    client.invoke_model_stream(generate_text_request, **opts, &block)
  end

  # @param [GenerateTextRequest] request object
  # @return [InvokeModelResponse] the object containing the generated text.
  def invoke_model(generate_text_request)
    client = self.class.client_for(generate_text_request).new
    client.invoke_model(generate_text_request)
  end
end
