class GenerativeImage
  module Stability
    # See https://platform.stability.ai/docs/api-reference

    ClientError = Class.new(StandardError)

    HOST = 'https://api.stability.ai'.freeze
    ENGINES_ENDPOINT = '/v1/engines/list'.freeze
    GENERATION_ENDPOINT = '/v1/generation/%<engine>s/text-to-image'.freeze
    CORE_GENERATION_ENDPOINT = '/v2beta/stable-image/generate/core'.freeze

    ENGINES = {
      v1_6: {
        id: 'stable-diffusion-v1-6', dimensions: %w[320x320 512x512 768x768]
      },
      xl_v1: {
        id: 'stable-diffusion-xl-1024-v1-0',
        dimensions: %w[1024x1024 1152x896 1216x832 1344x768 1536x640 640x1536 768x1344 832x1216 896x1152]
      }
    }.freeze

    DIMENSIONS = ENGINES.values.flat_map { |e| e[:dimensions] }

    STYLE_PRESETS = %w[
      3d-model
      analog-film
      anime
      cinematic
      comic-book
      digital-art
      enhance
      fantasy-art
      isometric
      line-art
      low-poly
      modeling-compound
      neon-punk
      origami
      photographic
      pixel-art
      tile-texture
    ].freeze

    CORE_ASPECT_RATIOS = %w[1:1 5:4 3:2 16:9 21:9 4:5 2:3 9:16 9:21].freeze

    DEFAULT_STYLE = 'photographic'.freeze
  end
end
