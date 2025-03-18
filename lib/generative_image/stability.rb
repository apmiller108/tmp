class GenerativeImage
  module Stability
    # See https://platform.stability.ai/docs/api-reference

    ClientError = Class.new(StandardError)

    HOST = 'https://api.stability.ai'.freeze
    ENGINES_ENDPOINT = '/v1/engines/list'.freeze

    CORE_GENERATION_ENDPOINT = '/v2beta/stable-image/generate/core'.freeze
    ULTRA_GENERATION_ENDPOINT = '/v2beta/stable-image/generate/ultra'.freeze

    CORE = :core
    ULTRA = :ultra

    TEXT_TO_IMAGE = 'text_to_image'.freeze
    IMAGE_TO_IMAGE = 'image_to_image'.freeze
    REQUEST_TYPES = [TEXT_TO_IMAGE, IMAGE_TO_IMAGE].freeze

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
  end
end
