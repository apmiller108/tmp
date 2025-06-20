module Anthropic
  class FilesClient
    BETA_VERSION = 'files-api-2025-04-14'.freeze

    attr_reader :conn

    def initialize
      @conn = Faraday.new(
        url: HOST,
        headers: {
          'x-api-key': ENV.fetch('ANTHROPIC_KEY'),
          'anthropic-version': VERSION,
          'anthropic-beta': BETA_VERSION
        }
      ) do |f|
        f.request :multipart
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
        f.options.timeout = 30
      end
    end

    # @param file [ActionDispatch::Http::UploadedFile]
    def upload_file(file)
      response = conn.post('/v1/files') do |req|
        req.body = {
          file: Faraday::UploadIO.new(
            file,
            file.content_type,
            file.original_filename
          )
        }
      end

      handle_response(response)
    ensure
      file.tempfile.close
      file.tempfile.unlink
    end

    def list_files
      response = conn.get('/v1/files')
      handle_response(response)
    end

    def get_file(file_id)
      response = conn.get("/v1/files/#{file_id}")
      handle_response(response)
    end

    def delete_file(file_id)
      response = conn.delete("/v1/files/#{file_id}")
      handle_response(response)
    end

    private

    def handle_response(response)
      case response.status
      when 200..299
        response.body
        # Anthropic::FileResponse.new(response.body)
      when 400..499
        handle_client_error(response)
      when 500..599
        handle_server_error(response)
      else
        # raise Anthropic::UnknownError, "Unexpected response status: #{response.status}"
      end
    end

    def handle_client_error(response)
      # error_data = response.body.dig('error') || {}
      # error_type = error_data['type']
      # error_message = error_data['message'] || 'Client error occurred'

      # case error_type
      # when 'invalid_request_error'
      #   raise Anthropic::InvalidRequestError, error_message
      # when 'authentication_error'
      #   raise Anthropic::AuthenticationError, error_message
      # when 'permission_error'
      #   raise Anthropic::PermissionError, error_message
      # when 'not_found_error'
      #   raise Anthropic::NotFoundError, error_message
      # when 'rate_limit_error'
      #   raise Anthropic::RateLimitError, error_message
      # when 'request_too_large'
      #   raise Anthropic::RequestTooLarge, error_message
      # else
      #   raise Anthropic::ClientError, error_message
      # end
    end

    def handle_server_error(response)
      # error_data = response.body.dig('error') || {}
      # error_type = error_data['type']
      # error_message = error_data['message'] || 'Server error occurred'

      # case error_type
      # when 'timeout_error'
      #   raise Anthropic::TimeoutError, error_message
      # when 'overloaded_error'
      #   raise Anthropic::OverloadedError, error_message
      # when 'api_error'
      #   raise Anthropic::APIError, error_message
      # else
      #   raise Anthropic::ServerError, error_message
      # end
    end
  end
end
