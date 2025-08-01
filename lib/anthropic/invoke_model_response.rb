module Anthropic
  class InvokeModelResponse
    attr_reader :data

    TOOL_USE = 'tool_use'.freeze

    # @param [Hash | String] data
    # Parsed JSON response will look like this.
    # {
    #     "id" => "msg_01DMcCdRr6gaWDuZs7Y63rhe",
    #     "type" => "message",
    #     "role" => "assistant",
    #     "content" => [{
    #         "type" => "text",
    #         "text" => "response content goes here"
    #     }],
    #     "model" => "claude-3-haiku-20240307",
    #     "stop_reason" => "end_turn",
    #     "stop_sequence" => nil,
    #     "usage" => {
    #         "input_tokens" => 79, "output_tokens" => 942,
    #         "cache_creation_input_tokens"=>0, "cache_read_input_tokens"=>1601
    #     }
    # }
    #
    # If the stop_reason is `tool_use`, the tool input objects will be in the
    # content array. Example tool_input object:
    #
    # { "id" => "toolu_01MdQEyXJfvM5hUpabMKKwMU",
    #   "name"=>"generate_image",
    #   "type"=>"tool_use",
    #   "input"=>{ "tool_use_input_json" => "here" }
    def initialize(data)
      @data = if data.respond_to? :keys
                data
              else
                JSON.parse(data)
              end
    end

    # This is the assistant response. Sometimes it will not be present if the
    # response contains a tool use block. In other words, there are rare
    # occassions where the response will only contain the tool use block.
    # @return [String, nil]
    def content
      results.find { |c| c['type'] == 'text' }&.fetch('text')
    end

    def results
      data.fetch('content')
    end

    def completion_reason
      # stop_reason could be one of ["end_turn", "max_tokens", "stop_sequence", "tool_use"]
      data.fetch('stop_reason')
    end

    def complete?
      completion_reason.present?
    end

    def tool_use?
      completion_reason == TOOL_USE
    end

    # Cache token keys were added later. Older responses won't have that key.
    def token_count
      input_token_count + output_token_count
    end

    def input_token_count
      usage.fetch('input_tokens') +
        usage.fetch('cache_creation_input_tokens', 0) + usage.fetch('cache_read_input_tokens', 0)
    end

    def output_token_count
      usage.fetch('output_tokens')
    end

    def usage
      data.fetch('usage')
    end

    def blobify
      [
        content,
        *tool_inputs.map { _1['input'] }
      ].join(' ')
    end

    def tool_inputs
      results.select { |c| c['type'] == TOOL_USE }
    end
  end
end
