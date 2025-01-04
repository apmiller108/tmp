class Conversation
  class Turn
    attr_reader :turn_data

    def self.for_prompt(prompt)
      new(
        {
          'role' => USER,
          'content' => [{ 'text' => prompt, 'type' => 'text' }]
        }
      )
    end

    def self.for_response(response)
      new({ 'role' => ASSISTANT, 'content' => response || 'no content' })
    end

    # @param [Array<Hash>] turn_data
    #  User prompt:
    #    { "role" => "user",
    #      "content" => [{ "text" => "Hello?", "type" => "text" }] }
    #  Assistant response:
    #    { "role" => "assistant",
    #      "content" => "Is it me you're looking for?" }
    def initialize(turn_data)
      @turn_data = turn_data
    end

    def assistant? = role == ASSISTANT

    def user? = role == USER

    def role
      turn_data['role']
    end

    def content
      if user?
        turn_data.fetch('content').first['text']
      else
        turn_data.fetch('content')
      end
    end
  end
end
