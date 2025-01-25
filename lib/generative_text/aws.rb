class GenerativeText
  module AWS
    def self.vendor = :aws
    def self.capabilities = Model::Capabilities.new(image?: false)

    MODELS = [
      Model.new(api_name: 'amazon.titan-text-express-v1', name: 'AWS Titan Express', vendor:, capabilities:, max_tokens: 8000)
    ].freeze
  end
end
