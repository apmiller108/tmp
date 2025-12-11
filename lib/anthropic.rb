# frozen_string_literal: true

module Anthropic
  VERSION = '2023-06-01'
  HOST = 'https://api.anthropic.com'
  MESSAGES_PATH = '/v1/messages'

  def self.vendor = :anthropic
  def self.capabilities = GenerativeText::Model::Capabilities.new(image?: true)

  # rubocop:disable Metrics/AbcSize
  def self.models
    [
      GenerativeText::Model.new(
        api_name: 'claude-3-haiku-20240307',
        name: 'Claude Haiku 3',
        vendor:,
        capabilities:,
        max_tokens: 4096,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'claude-3-5-haiku-latest',
        name: 'Claude Haiku 3.5 Latest',
        vendor:,
        capabilities:,
        max_tokens: 8192,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'claude-haiku-4-5',
        name: 'Claude Haiku 4.5',
        vendor:,
        capabilities:,
        max_tokens: 64_000,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'claude-sonnet-4-5-20250929',
        name: 'Claude Sonnet 4.5',
        vendor:,
        capabilities:,
        max_tokens: 64_000,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'claude-sonnet-4-0',
        name: 'Claude Sonnet 4 Latest',
        vendor:,
        capabilities:,
        max_tokens: 64_000,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'claude-3-7-sonnet-latest',
        name: 'Claude Sonnet 3.7 Latest',
        vendor:,
        capabilities:,
        max_tokens: 64_000,
        active?: false
      ),
      GenerativeText::Model.new(
        api_name: 'claude-3-5-sonnet-latest',
        name: 'Claude Sonnet 3.5 Latest',
        vendor:,
        capabilities:,
        max_tokens: 8192,
        active?: false
      ),
      GenerativeText::Model.new(
        api_name: 'claude-3-5-sonnet-20240620',
        name: 'Claude Sonnet 3.5',
        vendor:,
        capabilities:,
        max_tokens: 4096,
        active?: false
      ),
      GenerativeText::Model.new(
        api_name: 'claude-3-sonnet-20240229',
        name: 'Claude Sonnet 3',
        vendor:,
        capabilities:,
        max_tokens: 4096,
        active?: false
      ),
      GenerativeText::Model.new(
        api_name: 'claude-opus-4-0',
        name: 'Claude Opus 4',
        vendor:,
        capabilities:,
        max_tokens: 32_000,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'claude-3-opus-20240229',
        name: 'Claude Opus 3',
        vendor:,
        capabilities:,
        max_tokens: 4096,
        active?: false
      )
    ]
  end
  # rubocop:enable Metrics/AbcSize

  def self.active_models
    models.select(&:active?)
  end

  # Upload a file to Anthropic via Files API
  # @param file [ActionDispatch::UploadedFile]
  # @return [Anthropic::FileResponse]
  def self.upload_file(file)
    FilesClient.new.upload_file(file)
  end

  def self.delete_file(file_id)
    FilesClient.new.delete_file(file_id)
  end

  ClientError = Class.new(StandardError)
  InvalidRequestError = Class.new(StandardError)
  AuthenticationError = Class.new(StandardError)
  PermissionError = Class.new(StandardError)
  NotFoundError = Class.new(StandardError)
  RateLimitError = Class.new(StandardError)
  RequestTooLarge = Class.new(StandardError)
  TimeoutError = Class.new(StandardError)
  OverloadedError = Class.new(StandardError)
  APIError = Class.new(StandardError)
  ServerError = Class.new(StandardError)
  UnknownError = Class.new(StandardError)
end
