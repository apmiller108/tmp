class GenerativeText
  # GenerateText via AWS is not longer used. This is being kept in the event
  # there should be reason to use it in the future.
  module AWS
    def self.vendor = :aws
    def self.capabilities = Model::Capabilities.new(image?: false)

    MODELS = [
      Model.new(api_name: 'amazon.titan-text-express-v1',
                name: 'AWS Titan Express',
                vendor:,
                capabilities:,
                max_tokens: 8000,
                active?: false)
    ].freeze
  end
end
