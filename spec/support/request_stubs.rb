module RequestStubs
  def stub_anthropic_messages_request(**args)
    body = if args[:tool_use?]
             file_fixture('anthropic/messages_tool_use_response.json').read
           else
             file_fixture('anthropic/messages_response.json').read
           end

    messages = args.fetch(:messages, [])
                   .push({ 'role' => 'user', 'content' => [{ 'text' => args.fetch(:prompt), 'type' => 'text' }] })

    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(
        body: {
          model: args.fetch(:model).api_name,
          max_tokens: args.fetch(:model).max_tokens,
          stream: false,
          system: GenerateTextRequest.new(generate_text_preset: args.fetch(:generate_text_preset, nil)).system_message,
          tools: GenerativeText::Anthropic::ToolBox.all_tools.map(&:as_json),
          tool_choice: { type: 'auto' },
          temperature: args.fetch(:temperature),
          messages:
        }.to_json
      ).to_return(status: args.fetch(:response_status, 200), body: args.fetch(:response_body, body))
  end

  def stub_anthropic_stream_request(**args)
    body = if args[:tool_use?]
             file_fixture('anthropic/messages_stream_tool_use_response.txt').read
           else
             file_fixture('anthropic/messages_stream_response.txt').read
           end

    messages = args.fetch(:messages, [])
                   .push({ 'role' => 'user', 'content' => [{ 'text' => args.fetch(:prompt), 'type' => 'text' }] })

    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(
        body: {
          model: args.fetch(:model).api_name,
          max_tokens: args.fetch(:model).max_tokens,
          stream: true,
          system: GenerateTextRequest.new(generate_text_preset: args.fetch(:generate_text_preset, nil)).system_message,
          tools: GenerativeText::Anthropic::ToolBox.all_tools.map(&:as_json),
          tool_choice: { type: 'auto' },
          temperature: args.fetch(:temperature),
          messages:
        }.to_json
      ).to_return(status: args.fetch(:response_status, 200), body:, headers: { 'Content-Type' => 'text/event-stream' })
  end

  def stub_stability_core_request(**_args)
    png = file_fixture 'image.png'
    stub_request(:post, 'https://api.stability.ai/v2beta/stable-image/generate/core')
      .with(headers: {
        'Authorization': "Bearer #{Rails.application.credentials.fetch(:stability_key)}",
        'Accept': 'image/*'
      }).to_return(status: 200, body: png.read, headers: { 'seed' => 1234, 'finish-reason' => 'SUCCESS' })
  end
end
