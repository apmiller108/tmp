module Gemini
  class FilesClient
    # include ErrorHandling

    def initialize
      @api_key = ENV.fetch('GEMINI_API_KEY')
      @conn = Faraday.new(
        url: HOST,
        headers: {
          'Content-Type': 'application/json'
        }
      ) do |f|
        f.adapter :typhoeus
      end
    end

    # @param file [ActionDispatch::Http::UploadedFile]
    # @return [Gemini::FileResponse]
    def upload_file(file)
      # 1. Initiate Resumable Upload
      init_url = "/upload/#{VERSION}/files?key=#{@api_key}"
      
      file.rewind
      content = file.read
      file_size = content.bytesize.to_s
      
      init_response = conn.post(init_url) do |req|
        req.headers['X-Goog-Upload-Protocol'] = 'resumable'
        req.headers['X-Goog-Upload-Command'] = 'start'
        req.headers['X-Goog-Upload-Header-Content-Length'] = file_size
        req.headers['X-Goog-Upload-Header-Content-Type'] = file.content_type
        req.headers['Content-Type'] = 'application/json'
        req.body = { file: { display_name: file.original_filename } }.to_json
      end

      unless init_response.status.in?(200..299)
        raise "Gemini File Upload Init Failed: #{init_response.status} - #{init_response.body}"
      end
      
      upload_url = init_response.headers['x-goog-upload-url']
      
      # 2. Upload Bytes
      # We use a new Faraday request for the upload_url as it is absolute
      upload_response = Faraday.put(upload_url) do |req|
        req.headers['Content-Length'] = file_size
        req.headers['X-Goog-Upload-Offset'] = '0'
        req.headers['X-Goog-Upload-Command'] = 'upload, finalize'
        req.body = content
      end

      if upload_response.status.in?(200..299)
        FileResponse.for(JSON.parse(upload_response.body).dig('file'))
      else
        raise "Gemini File Upload Failed: #{upload_response.status} - #{upload_response.body}"
      end
    end

    def delete_file(file_id)
      # file_id might be "files/..." or "https://.../files/..."
      # Extract "files/..."
      if file_id.start_with?('http')
        file_id = file_id.split('/v1beta/').last
        # Verify it starts with files/ just in case
        unless file_id&.start_with?('files/')
           # Fallback or error
           file_id = file_id # Attempt to use as is
        end
      end
      
      url = "/#{VERSION}/#{file_id}?key=#{@api_key}"
      
      response = conn.delete(url)
      
      unless response.status.in?(200..299)
        raise "Gemini File Delete Failed: #{response.status} - #{response.body}"
      end
      
      true
    end
    
    def get_file(file_id)
       url = "/#{VERSION}/#{file_id}?key=#{@api_key}"
       response = conn.get(url)
       
       if response.status.in?(200..299)
         FileResponse.for(JSON.parse(response.body))
       else
         raise "Gemini Get File Failed: #{response.status} - #{response.body}"
       end
    end
  end
end
