class GenerativeImage
  module Stability
    class TextToImageRequestV2
      attr_reader :prompts, :opts

      # @param [Array<Hash>] prompts { 'text' => 'foo' 'weight' => 1 }
      def initialize(prompts:, **opts)
        @prompts = prompts
        @opts = default_opts.merge(opts.compact).symbolize_keys
      end

      def as_json
        {
          prompt:,
          negative_prompt:,
          style_preset: opts[:style],
          aspect_ratio: opts[:aspect_ratio],
          seed: opts[:seed]
        }.compact
      end

      def path
        CORE_GENERATION_ENDPOINT
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
          aspect_ratio: CORE_ASPECT_RATIOS.first,
          seed: 0
        }
      end
    end
  end
end
