class GenerativeImage
  module Stability
    class TextToImageRequestV2
      attr_reader :prompts, :opts

      def initialize(prompts:, **opts)
        @prompts = prompts.to_a # convert to ruby Array in case it is ActiveRecord::Relation
        @opts = default_opts.merge(opts.compact).symbolize_keys
      end

      def as_json
        {
          prompt:,
          negative_prompt:,
          style_preset: opts[:style],
          aspect_ratio: opts[:aspect_ratio],
          seed: opts[:seed]
        }
      end

      def path
        CORE_GENERATION_ENDPOINT
      end

      private

      def prompt
        prompts.find(&:positive?)
      end

      def negative_prompt
        prompts.find(&:positive?)
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
