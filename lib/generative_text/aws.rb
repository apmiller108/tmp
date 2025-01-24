class GenerativeText
  module AWS
    def self.vendor = :aws

    MODELS = [
      Model.new(api_name: 'amazon.titan-text-express-v1', name: 'AWS Titan Express', vendor:, max_tokens: 8000),
      Model.new(api_name: 'meta.llama2-70b-chat-v1', name: 'Llama 2 70b', vendor:, max_tokens: 4000)
    ].freeze
  end
end
