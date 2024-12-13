class Conversation
  class Turn
    attr_reader :exchange_part

    def self.for_prompt(prompt)
      new(
        {
          'role' => USER,
          'content' => [{ 'text' => prompt, 'type' => 'text' }]
        }
      )
    end

    def self.for_response(response)
      new({ 'role' => ASSISTANT, 'content' => response })
    end

    # @param [Array<Hash>] exchange_part
    #  User prompt:
    #    { "role" => "user",
    #      "content" => [{ "text" => "Hello?", "type" => "text" }] }
    #  Assistant response:
    #    { "role" => "assistant",
    #      "content" => "Is it me you're looking for?" }
    def initialize(exchange_part)
      @exchange_part = exchange_part
    end

    def assistant? = role == ASSISTANT

    def user? = role == USER

    def role
      exchange_part['role']
    end

    def content
      if user?
        exchange_part.fetch('content').first['text']
      else
        exchange_part.fetch('content')
      end
    end
  end
end
