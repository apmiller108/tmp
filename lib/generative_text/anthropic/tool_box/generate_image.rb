# frozen_string_literal: true

class GenerativeText
  module Anthropic
    module ToolBox
      class GenerateImage
        NAME = 'generate_image'
        DESCRIPTION = <<~TXT
          Creates a request to generate an image using a Stable Diffusion
          generative image AI model. A prompt and aspect ratio are required.
          Optimize the prompt to produce the best image possible. Use adjectives
          and detailed descriptive phrases. Be clear about the subject or main
          focal point of the image. To control the weight of a given word use
          the format (word:weight), where word is the word you'd like to control
          the weight of and weight is a value between 0 and 1. For example: The
          sky was a crisp (blue:0.3) and (green:0.8) would convey a sky that was
          blue and green, but more green than blue. A negative prompt and style
          are optional, but should be used where needed to produce the most
          optimal image. This tool should be used when the user is asking you to
          create an image.
        TXT

        def input_schema
          {
            'type' => 'object',
            'properties' => {
              'options' => {
                'type' => 'object',
                'properties' => {
                  'style' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::Stability::STYLE_PRESETS,
                    'description' => "Preset used to guide the model's stylistic output."
                  },
                  'aspect_ratio' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::Stability::CORE_ASPECT_RATIOS,
                    'description' => 'Image dimensions.'
                  }
                },
                'required' => ['aspect_ratio']
              },
              'prompts' => {
                'description' => 'Prompt and negative prompt to generate an image using Stable Diffusion.',
                'type' => 'object',
                'properties' => {
                  'prompt' => {
                    'type' => 'string',
                    'description' => 'Prompt to generate an image using Stable Diffusion.'
                  },
                  'negative_prompt' => {
                    'type' => 'string',
                    'description' => 'Negative prompt to generate an image using Stable Diffusion.'
                  }
                },
                'required' => ['prompt']
              }
            },
            'required' => %w[options prompts]
          }
        end

        def to_h
          {
            name: NAME,
            description: DESCRIPTION,
            input_schema:
          }
        end

        def as_json = to_h
      end
    end
  end
end
