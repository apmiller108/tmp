class GenerativeImage
  module Stability
    # See https://platform.stability.ai/docs/api-reference

    HOST = 'https://api.stability.ai'.freeze
    ENGINES_ENDPOINT = '/v1/engines/list'.freeze
    GENERATION_ENDPOINT = '/v1/generation/%<engine>s/text-to-image'.freeze

    ENGINES = {
      v1_6: {
        id: 'stable-diffusion-v1-6', dimensions: %w[320x320 512x512 768x768]
      },
      xl_v1: {
        id: 'stable-diffusion-xl-1024-v1-0',
        dimensions: %w[1024x1024 1152x896 1216x832 1344x768 1536x640 640x1536 768x1344 832x1216 896x1152]
      }
    }.freeze

    STYLE_PRESETS = {
      '3d_model': '3d-model',
      analog_film: 'analog-film',
      anime: 'anime',
      cinematic: 'cinematic',
      comic_book: 'comic-book',
      digital_art: 'digital-art',
      enhance: 'enhance',
      fantasy_art: 'fantasy-art',
      isometric: 'isometric',
      line_art: 'line-art',
      low_poly: 'low-poly',
      modeling_compound: 'modeling-compound',
      neon_punk: 'neon-punk',
      origami: 'origami',
      photographic: 'photographic',
      pixel_art: 'pixel-art',
      tile_texture: 'tile-texture'
    }.freeze
  end
end
