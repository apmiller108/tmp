class GenerativeText
  module AWS
    def self.vendor = :aws

    MODELS = [
      Model.new(api_name: 'amazon.titan-text-express-v1', name: 'AWS Titan Express', vendor:, max_tokens: 8000),
    ].freeze
  end
end
