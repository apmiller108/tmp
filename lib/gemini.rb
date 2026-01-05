# frozen_string_literal: true

module Gemini
  HOST = 'https://generativelanguage.googleapis.com'
  VERSION = 'v1beta'

  def self.vendor = :google
  def self.capabilities = GenerativeText::Model::Capabilities.new(image?: true)

  def self.models
    [
      GenerativeText::Model.new(
        api_name: 'gemini-2.5-flash',
        name: 'Gemini 2.5 Flash',
        vendor:,
        capabilities:,
        max_tokens: 65_536,
        active?: true
      ),
      GenerativeText::Model.new(
        api_name: 'gemini-2.5-pro',
        name: 'Gemini 2.5 Pro',
        vendor:,
        capabilities:,
        max_tokens: 65_536,
        active?: true
      ),
    ]
  end

  def self.active_models
    models.select(&:active?)
  end

  def self.upload_file(file)
    Gemini::FilesClient.new.upload_file(file)
  end

  def self.delete_file(file_id)
    Gemini::FilesClient.new.delete_file(file_id)
  end

  class Error < StandardError; end
  class ClientError < Error; end
  class ServerError < Error; end
end
