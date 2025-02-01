class GenerativeText
  module Anthropic
    module ToolBox
      class GenerateImage
        def name
          :generate_image
        end

        def description
          'Create a request to generate an image using a JSON API for a Stable Diffusion model'
        end

        def input_schema
          {
            'type' => 'object',
            'properties' => {
              'image_name' => { 'type' => 'string', 'description' => 'image name' },
              'options' => {
                'type' => 'object',
                'properties' => {
                  'style' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::Stability::STYLE_PRESETS,
                    'description' => "preset used to guide the model's stylistic output"
                  },
                  'aspect_ratio' => {
                    'type' => 'string',
                    'enum' => GenerativeImage::Stability::CORE_ASPECT_RATIOS,
                    'description' => 'image dimensions'
                  }
                },
                'required' => ['aspect_ratio']
              },
              'prompts' => {
                'description' => 'The prompt and an optional negative prompt to generate an image using Stable Diffusion',
                'type' => 'object',
                'properties' => {
                  'prompt' => {
                    'type' => 'string',
                    'description' => 'a prompt to generate an image using Stable Diffusion'
                  },
                  'negative_prompt' => {
                    'type' => 'string',
                    'description' => 'a negative prompt to generate an image using Stable Diffusion'
                  }
                },
                'required' => ['prompt']
              }
            }
          }
        end

        def to_h
          {
            name:,
            description:,
            input_schema:
          }
        end

        def as_json = to_h
      end
    end
  end
end
