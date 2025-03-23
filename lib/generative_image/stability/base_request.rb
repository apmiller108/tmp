class GenerativeImage
  module Stability
    class BaseRequest
      attr_reader :generate_image_request

      delegate :prompt, :negative_prompt, to: :generate_image_request

      # @param generate_image_request [GenerateImageRequest]
      def initialize(generate_image_request)
        @generate_image_request = generate_image_request
      end

      def as_json
        {
          prompt:,
          negative_prompt:,
          style_preset: opts[:style].presence,
          aspect_ratio: opts[:aspect_ratio],
          output_format: opts[:output_format],
          seed: opts[:seed]
        }.compact
      end

      # Subclasses must implement this.
      def path; end

      def close
        # No-op by default, subclasses can override
      end

      private

      def opts
        @opts ||= default_opts.merge(request_options)
      end

      def default_opts
        {
          style: DEFAULT_STYLE,
          aspect_ratio: ASPECT_RATIOS.first,
          seed: 0,
          output_format: 'png'
        }
      end

      def request_options
        generate_image_request.parameterize.compact.symbolize_keys
      end
    end
  end
end
