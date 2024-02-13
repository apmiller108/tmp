class GenerativeImage
  module Stability
    class TextToImageRequest
      attr_reader :prompt, :opts

      def initialize(prompt:, **opts)
        @prompt = prompt
        @opts = default_opts.merge(opts)
      end

      # Optionally add prompts with different weights to (de)emphasize concepts.
      # Weights can be negative in order to suppress concepts.
      def as_json
        {
          text_prompts: [{ text: prompt, weight: 1 }],
          style_preset: opts[:style],
          height: dimensions[1],
          width: dimensions[0],
          **opts.slice(:cfg_scale, :samples, :seed, :steps)
        }
      end

      def path
        format(GENERATION_ENDPOINT, engine: engine[:id])
      end

      private

      def default_opts
        {
          dimensions: ENGINES.dig(:v1_6, :dimensions).first,
          style: DEFAULT_STYLE,
          cfg_scale: 10, # Number (10..35). How strictly to adhere to the prompt.
          samples: 1, # Number of images to generate
          seed: 0, # 0 represents random seed
          steps: 30 # 10..50
        }
      end

      def engine
        ENGINES.values.find { |e| e[:dimensions].include?(opts[:dimensions]) }
      end

      def dimensions
        opts.fetch(:dimensions).split('x').map(&:to_i)
      end
    end
  end
end
