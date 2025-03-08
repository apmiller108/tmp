# frozen_string_literal: true

class GenerativeText
  module Anthropic
    VERSION = '2023-06-01'
    HOST = 'https://api.anthropic.com/'
    MESSAGES_PATH = '/v1/messages'

    def self.vendor = :anthropic
    def self.capabilities = Model::Capabilities.new(image?: true)

    MODELS = [
      Model.new(api_name: 'claude-3-haiku-20240307',
                name: 'Claude 3 Haiku',
                vendor:,
                capabilities:,
                max_tokens: 4096,
                active?: true),
      Model.new(api_name: 'claude-3-5-haiku-latest',
                name: 'Claude 3.5 Haiku Latest',
                vendor:,
                capabilities:,
                max_tokens: 8192,
                active?: true),
      Model.new(api_name: 'claude-3-7-sonnet-latest',
                name: 'Claude 3.7 Sonnet Latest',
                vendor:,
                capabilities:,
                max_tokens: 8192,
                active?: true),
      Model.new(api_name: 'claude-3-5-sonnet-latest',
                name: 'Claude 3.5 Sonnet Latest',
                vendor:,
                capabilities:,
                max_tokens: 8192,
                active?: false),
      Model.new(api_name: 'claude-3-5-sonnet-20240620',
                name: 'Claude 3.5 Sonnet',
                vendor:,
                capabilities:,
                max_tokens: 4096,
                active?: false),
      Model.new(api_name: 'claude-3-sonnet-20240229',
                name: 'Claude 3 Sonnet',
                vendor:,
                capabilities:,
                max_tokens: 4096,
                active?: false),
      Model.new(api_name: 'claude-3-opus-20240229',
                name: 'Claude 3 Opus',
                vendor:,
                capabilities:,
                max_tokens: 4096,
                active?: false)
    ].freeze

    def self.active_models
      MODELS.select(&:active?)
    end
    ClientError = Class.new(StandardError)
  end
end
