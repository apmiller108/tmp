class GenerativeImage
  module Stability
    class UltraRequest < BaseRequest
      def as_json
        super.tap do |payload|
          if base_image.present?
            payload[:image] = image_upload_io
            payload[:strength] = opts.fetch(:strength)
          end
        end
      end

      def path
        ULTRA_GENERATION_ENDPOINT
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
        super.merge({ strength: 0.7 })
      end
    end
  end
end
