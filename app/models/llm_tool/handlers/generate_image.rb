class LlmTool
  module Handlers
    class GenerateImage
      attr_reader :input

      # @param input [Hash] a hash that matches the GenerateImage JSON schema.
      def initialize(input)
        @input = input
      end

      def call(generate_text_request)
        form = GenerateImageRequestForm.new(image_request_params(generate_text_request))

        if form.submit
          Conversations::GenerateImageJob.perform_async(form.generate_image_request.id)
          true
        else
          false
        end
      end

      def image_request_params(generate_text_request)
        {
          **input['options'],
          **input['prompts'],
          **generate_text_request.slice(:user, :conversation),
          'generate_text_request' => generate_text_request
        }
      end
    end
  end
end
