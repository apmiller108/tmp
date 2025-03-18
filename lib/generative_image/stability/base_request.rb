class GenerativeImage
  module Stability
    class BaseRequest
      attr_reader :prompts, :opts

      def initialize(prompts:, **opts)
        @prompts = prompts
        @opts = default_opts.merge(opts.compact.symbolize_keys)
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

      def path
        raise NotImplementedError, 'Subclasses must implement #path'
      end

      def close
        # No-op by default, subclasses can override
      end

      protected

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
          output_format: 'png'
        }
      end
    end
  end
end
