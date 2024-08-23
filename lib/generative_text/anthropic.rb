class GenerativeText
  module Anthropic
    VERSION = '2023-06-01'.freeze
    HOST = 'https://api.anthropic.com/'.freeze
    MESSAGES_PATH = '/v1/messages'.freeze

    HAIKU3 = 'claude-3-haiku-20240307'.freeze
    SONNET3 = 'claude-3-sonnet-20240229'.freeze
    SONNET35 = 'claude-3-5-sonnet-20240620'.freeze
    OPUS3 = 'claude-3-opus-20240229'.freeze

    Model = Struct.new(:api_name, :name, :max_tokens, keyword_init: true)

    MODELS = {
      haiku3: Model.new(api_name: HAIKU3, name: 'Claude 3 Haiku', max_tokens: 4096),
      sonnet3: Model.new(api_name: SONNET3, name: 'Claude 3 Sonnet', max_tokens: 4096),
      sonnet35: Model.new(api_name: SONNET35, name: 'Claude 3.5 Sonnet', max_tokens: 8192),
      opus3: Model.new(api_name: OPUS3, name: 'Claude 3 Opus', max_tokens: 4096)
    }.with_indifferent_access.freeze

    DEFAULT_MODEL = MODELS.fetch(:haiku3)

    ClientError = Class.new(StandardError)
  end
end
