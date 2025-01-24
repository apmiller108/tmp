class GenerativeText
  module AWS
    class Client
      class InvokeModelResponse
        attr_reader :data

        # JSON response will look like this
        # {"inputTextTokenCount"=>5,
        #   "results"=>
        #     [{"tokenCount"=>55,
        #       "outputText"=> "\nHere are 10 fruits:\n1. Apple\n2. Banana\n3..."
        #       "completionReason"=>"FINISH"}]}
        def initialize(data)
          @data = if data.respond_to? :keys
                    data
                  else
                    JSON.parse(data)
                  end
        end

        def content
          results.fetch('outputText')
        end

        def results
          data.fetch('results')[0]
        end

        def completion_reason
          # completionReason could be one of ["LENGTH", "FINISH"]. The latter
          # meaning the response was truncated per the max_tokens.
          results.fetch('completionReason')
        end

        def token_count
          (data['inputTextTokenCount'] || 0) + (results['tokenCount'] || 0)
        end
      end
    end
  end
end
