class GenerativeText
  InvalidRequestError = Class.new(StandardError)

  Model = Struct.new(:api_name, :name, :max_tokens, :vendor, :capabilities, keyword_init: true)
  Model::Capabilities = Struct.new(:images, :presets)

  MODELS = [
    *Anthropic::MODELS,
    *AWS::MODELS
  ]

  DEFAULT_MODEL = MODELS.find { _1.api_name == 'claude-3-5-haiku-latest' }

  def self.summary_prompt_for(transcription:)
    Prompt.transcription_summary_prompt(transcription)
  end

  def self.client_for(generate_text_request)
    case generate_text_request.model.vendor
    when :aws
      AWS::Client
    when :anthropic
      Anthropic::Client
    end
  end

  # The block is what should yield to each stream chunk
  # Only the AWS client supports streaming at this time
  def invoke_model_stream(prompt:, client: AWS::Client.new, **opts, &block)
    client.invoke_model_stream(prompt:, **opts, &block)
  end

  # @param [GenerateTextRequest] request object
  # @return [InvokeModelResponse] the object containing the generated text.
  def invoke_model(generate_text_request)
    client = self.class.client_for(generate_text_request).new
    client.invoke_model(generate_text_request)
  end
end
