class GenerativeImage
  module Stability
    class UltraImageRequest
      attr_reader :prompts, :image_data, :opts

      # @param [Array<Hash>] prompts { 'text' => 'foo' 'weight' => 1 }
      # @param [String, nil] image_data Binary image data for image-to-image requests
      def initialize(prompts:, image_data: nil, **opts)
        @prompts = prompts
        @image_data = image_data
        @opts = default_opts.merge(opts.compact.symbolize_keys)
      end

      def as_json
        {
          prompt:,
          negative_prompt:,
          aspect_ratio: opts[:aspect_ratio],
          seed: opts[:seed],
          style_preset: opts[:style].presence,
          output_format: opts[:output_format]
        }.tap do |payload|
          if image_data.present?
            # Add image and strength for image-to-image requests
            payload[:image] = image_data
            payload[:strength] = opts[:strength]
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
