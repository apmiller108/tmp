class GenerativeText
  module Anthropic
    VERSION = '2023-06-01'.freeze
    HOST = 'https://api.anthropic.com/'.freeze
    MESSAGES_PATH = '/v1/messages'.freeze
    HAIKU = 'claude-3-haiku-20240307'.freeze
    SONNET = 'claude-3-sonnet-20240229'.freeze
    MAX_TOKENS = 1024 # 4096 is the max output
    ClientError = Class.new(StandardError)
  end
end
