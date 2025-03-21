# frozen_string_literal: true

class GenerativeText
  module Anthropic
    module ToolBox
      class GenerateImage
        NAME = 'generate_image'
        DESCRIPTION = <<~TXT
          This tool creates a request to generate an image using a Stable
          Diffusion generative image AI model. Your job is to turn the user's
          request to generate an image into a detailed, thoughtful and effective
          prompt to produce the best image possible. Use adjectives and detailed
          descriptive phrases. Be clear about the subject or main focal point of
          the image. To control the weight of a given word use the format
          (word:weight), where word is the word you'd like to control the weight
          of and weight is a value between 0 and 1. For example: The sky was a
          crisp (blue:0.3) and (green:0.8) would convey a sky that was blue and
          green, but more green than blue.

          Negative prompt and style are optional, but should be used where
          needed to produce the most optimal results.

          IMPORTANT: You MUST select the appropriate `request_type`:
          - Use `text_to_image` ONLY when the user is providing text without any reference images.
          - Use `image_to_image` whenever the user has uploaded, attached, or shared an image AND is asking to
            modify it, use it as a base, or generate something similar. Look for phrases like "based on this image",
            "edit this picture", "using this image", or when an image is clearly visible in the conversation.

          When using `image_to_image`, you should also set an appropriate `strength` value (between 0-1):
          - Lower values (0.1-0.4): Maintain more of the original image's composition and details
          - Medium values (0.5-0.7): Balance between original image and new elements
          - Higher values (0.8-0.95): More dramatic changes while keeping some influence from original

          This tool should ONLY be used when the user is EXPLICITLY asking you
          to create a new image or update an image. Do not create or update
          images without being explicitly asked. It's very important that you
          use the input schema precisely.
        TXT

        def input_schema
          {
            'type' => 'object',
            'properties' => {
              'options' => {
                'type' => 'object',
                'properties' => {
                  'request_type' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::REQUEST_TYPES,
                    'description' => 'The type of image generation request. See tool description.'
                  },
                  'style' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::Stability::STYLE_PRESETS,
                    'description' => "Preset used to guide the model's stylistic output."
                  },
                  'aspect_ratio' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::Stability::ASPECT_RATIOS,
                    'description' => 'Image dimensions.'
                  },
                  'strength' => {
                    'type' => 'number',
                    'minimum' => 0,
                    'maximum' => 1,
                    'description' => 'Sometimes referred to as denoising, this parameter controls how much influence the image parameter has on the generated image. A value of 0 would yield an image that is identical to the input. A value of 1 would be as if you passed in no image at all. Only used for image to image requests.'
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
