class GenerativeText
  InvalidRequestError = Class.new(StandardError)

  Model = Struct.new('Model', :api_name, :name, :max_tokens, :vendor, :capabilities, :active?, keyword_init: true)
  Model::Capabilities = Struct.new('ModelCapabilities', :image?)

  MODELS = [
    *Anthropic::MODELS,
    *AWS::MODELS
  ].freeze

  def self.find_model(api_name)
    MODELS.find { _1.api_name == api_name }.tap do |model|
      raise "Model not found: #{api_name}" if model.nil?
    end
  end

  DEFAULT_MODEL = find_model 'claude-3-5-haiku-latest'
  SUMMARY_MODEL = find_model 'claude-3-haiku-20240307'

  def self.active_models
    MODELS.select(&:active?)
  end

  def self.summary_prompt_for(transcription:)
    Helpers.transcription_summary_prompt(transcription)
  end

  # AWS models have been disabled
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
