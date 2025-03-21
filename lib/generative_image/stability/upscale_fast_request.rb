class GenerativeImage
  module Stability
    class UpscaleFastRequest < BaseRequest
      def as_json
        {
          image: image_upload_io,
          output_format: opts[:output_format]
        }.compact
        end

      def path
        UPSCALE_FAST_ENDPOINT
      end

      def base_image
        return @base_image if defined? @base_image

        @base_image = generate_image_request.base_image
      end

      def close
        return if @tempfile.nil?

        @tempfile.close
        @tempfile.unlink
      end

      private

      def image_upload_io
        @tempfile = Tempfile.new("tmp-#{base_image.filename}")
        @tempfile.binmode
        @tempfile.write(base_image.download)
        @tempfile.rewind
        Faraday::UploadIO.new(@tempfile.path, base_image.content_type, base_image.filename.to_s)
      end

      def default_options
        {
          output_format: 'png'
        }
      end
    end
  end
end
