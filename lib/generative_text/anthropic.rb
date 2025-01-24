# frozen_string_literal: true

class GenerativeText
  module Anthropic
    VERSION = '2023-06-01'.freeze
    HOST = 'https://api.anthropic.com/'.freeze
    MESSAGES_PATH = '/v1/messages'.freeze

    def self.vendor = :anthropic

    MODELS = [
      Model.new(api_name: 'claude-3-haiku-20240307', name: 'Claude 3 Haiku', vendor:, max_tokens: 4096),
      Model.new(api_name: 'claude-3-5-haiku-latest', name: 'Claude 3.5 Haiku Latest', vendor:, max_tokens: 8192),
      Model.new(api_name: 'claude-3-5-sonnet-latest', name: 'Claude 3.5 Sonnet Latest', vendor:, max_tokens: 8192),
      Model.new(api_name: 'claude-3-sonnet-20240229', name: 'Claude 3 Sonnet', vendor:, max_tokens: 4096),
      Model.new(api_name: 'claude-3-opus-20240229', name: 'Claude 3 Opus', vendor:, max_tokens: 4096)
    ].freeze

    ClientError = Class.new(StandardError)
  end
end
