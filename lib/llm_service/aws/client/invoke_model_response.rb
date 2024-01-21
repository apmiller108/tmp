class LLMService
  module AWS
    class Client
      class InvokeModelResponse
        attr_reader :response_data

        # JSON response will look like this
        # {"inputTextTokenCount"=>5,
        #   "results"=>
        #     [{"tokenCount"=>55,
        #       "outputText"=> "\nHere are 10 fruits:\n1. Apple\n2. Banana\n3..."
        #       "completionReason"=>"FINISH"}]}
        def initialize(json)
          @response_data = JSON.parse(json)
        end

        def content
          results.fetch('outputText')
        end

        def results
          response_data.fetch('results')[0]
        end

        def completion_reason
          # completionReason could be one of ["LENGTH", "FINISH"]. The latter
          # meaning the response was truncated per the max_tokens.
          results.fetch('completionReason')
        end

        def token_count
          (response_data['inputTokenCount'] || 0) + (results['outputTokenCount'] || 0)
        end
      end
    end
  end
end
