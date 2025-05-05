class LlmTool
  module Handlers
    class GenerateImage
      attr_reader :input, :user, :conversation

      # @param input [Hash] a hash that matches the GenerateImage JSON schema
      def initialize(input:, user:, conversation: nil)
        @input = input
        @user = user
        @conversation = conversation
      end

      def call
      end
    end
  end
end
