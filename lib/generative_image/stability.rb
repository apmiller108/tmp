class GenerativeImage
  module Stability
    # See https://platform.stability.ai/docs/api-reference

    ClientError = Class.new(StandardError)

    HOST = 'https://api.stability.ai'.freeze
    ENGINES_ENDPOINT = '/v1/engines/list'.freeze
    CORE_GENERATION_ENDPOINT = '/v2beta/stable-image/generate/core'.freeze
    ULTRA_GENERATION_ENDPOINT = '/v2beta/stable-image/generate/ultra'.freeze
    SD3_GENERATION_ENDPOINT = '/v2beta/stable-image/generate/sd3'.freeze

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

    ASPECT_RATIOS = %w[1:1 5:4 3:2 16:9 21:9 4:5 2:3 9:16 9:21].freeze

    DEFAULT_STYLE = 'photographic'.freeze

    # CORE

    # Required:
    # prompt
    #
    # Optional:
    # aspect_ratio
    # negative_prompt
    # seed
    # style_preset
    # output_format

    # ULTRA

    # Required:
    # prompt
    #
    # Optional
    # image - the image to use as the starting point for the generation
    # strength - controls how much influence the image parameter has on the output image
    # aspect_ratio - the aspect ratio of the output image
    # negative_prompt - keywords of what you do not wish to see in the output image
    # seed - the randomness seed to use for the generation
    # output_format - the the format of the output image

  end
end
