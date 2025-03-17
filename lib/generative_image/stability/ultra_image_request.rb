class GenerativeImage
  module Stability
    class UltraImageRequest
      attr_reader :prompts, :base_image, :opts

      # @param [Array<Hash>] prompts { 'text' => 'foo' 'weight' => 1 }
      # @param [String, nil] base_image Binary image data for image-to-image requests
      def initialize(prompts:, base_image: nil, **opts)
        @prompts = prompts
        @base_image = base_image
        @opts = default_opts.merge(opts.compact.symbolize_keys)
      end

      def as_json
        {
          prompt:,
          negative_prompt:,
          aspect_ratio: opts[:aspect_ratio],
          seed: opts[:seed],
          style_preset: opts[:style].presence,
          output_format: opts.fetch(:output_format, 'png')
        }.tap do |payload|
          if base_image.present?
            # Add image and strength for image-to-image requests
            payload[:image] = base_image.download
            payload[:strength] = opts.fetch(:strength, 0.7)
          end
        end.compact
      end

      def path
        ULTRA_GENERATION_ENDPOINT
      end

      private

      def prompt
        prompts.find { |p| p.fetch('weight').positive? }
               .fetch('text')
      end

      def negative_prompt
        (prompts.find { |p| p.fetch('weight').negative? } || {})['text']
      end

      def default_opts
        {
          style: DEFAULT_STYLE,
          aspect_ratio: ASPECT_RATIOS.first,
          seed: 0,
          output_format: 'png',
          strength: 0.7 # Default strength for image-to-image
        }
      end
    end
  end
end
