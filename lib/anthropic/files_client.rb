module Anthropic
  class FilesClient
    include ErrorHandling

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
        # TODO Anthropic::FileResponse.new(response.body)
      else
        handle_error(response)
      end
    end
  end
end
