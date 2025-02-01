class GenerativeText
  module Anthropic
    module ToolBox
      module_function

      def all_tools
        [
          GenerateImage.new
        ]
      end
    end
  end
end
