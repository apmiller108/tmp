module Anthropic
  module ErrorHandling
    def handle_error(response, req_body = {}.to_json)
      error_data = begin
        JSON.parse(response.body).fetch('error', {})
      rescue JSON::ParserError
        {}
      end

      error_type = error_data['type']
      error_message = error_data.fetch('message', 'No error message from server')

      case response.status
      when 400..499
        handle_client_error(error_type:, error_message:, req_body:)
      when 500..599
        handle_server_error(response)
      else
        raise UnknownError, response.body
      end
    end

    def handle_client_error(error_type:, error_message:, req_body:)
      case error_type
      when 'invalid_request_error'
        raise Anthropic::InvalidRequestError, "#{error_message}: Check request body: \n\n#{JSON.parse(req_body)}"
      when 'authentication_error'
        raise Anthropic::AuthenticationError, error_message
      when 'permission_error'
        raise Anthropic::PermissionError, error_message
      when 'not_found_error'
        raise Anthropic::NotFoundError, error_message
      when 'rate_limit_error'
        raise Anthropic::RateLimitError, error_message
      when 'request_too_large'
        raise Anthropic::RequestTooLarge, error_message
      else
        raise Anthropic::ClientError, "#{error_message}: Check request body: \n\n#{JSON.parse(req_body)}"
      end
    end

    def handle_server_error(error_type:, error_message:)
      case error_type
      when 'timeout_error'
        raise Anthropic::TimeoutError, error_message
      when 'overloaded_error'
        raise Anthropic::OverloadedError, error_message
      when 'api_error'
        raise Anthropic::APIError, error_message
      else
        raise Anthropic::ServerError, error_message
      end
    end
  end
end
