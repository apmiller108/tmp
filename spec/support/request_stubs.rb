module RequestStubs
  def stub_anthropic_request(**args)
    body = { 'id' => 'msg_01DMcCdRr6gaWDuZs7Y63rhe',
             'type' => 'message',
             'role' => 'assistant',
             'content' => [{ 'type' => 'text',
                             'text' => args.fetch(:assistant_response, 'test assistant response') }],
             'model' => 'claude-3-haiku-20240307',
             'stop_reason' => 'end_turn',
             'stop_sequence' => nil,
             'usage' => { 'input_tokens' => 79, 'output_tokens' => 942, 'cache_creation_input_tokens' => 0,
                          'cache_read_input_tokens' => 0 } }.tap do |b|
      if args.fetch(:tool_use?, false)
        b['stop_reason'] = 'tool_use'
        b['content'] << {
          'id' => 'toolu_0196KvCx6JumrjS1g6qvN14H',
          'name' => 'generate_image',
          'type' => 'tool_use',
          'input' =>
           { 'options' => { 'style' => 'fantasy-art', 'aspect_ratio' => '16:9' },
             'prompts' =>
            { 'prompt' => 'image prompt',
              'negative_prompt' => 'negative prompt' } }
        }
      end
    end

    messages = args.fetch(:messages, [])
                   .push({ 'role' => 'user', 'content' => [{ 'text' => args.fetch(:prompt), 'type' => 'text' }] })

    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(
        body: {
          model: args.fetch(:model).api_name,
          max_tokens: args.fetch(:model).max_tokens,
          system: GenerateTextRequest.new(generate_text_preset: args.fetch(:generate_text_preset, nil)).system_message,
          tools: GenerativeText::Anthropic::ToolBox.all_tools.map(&:as_json),
          tool_choice: { type: 'auto' },
          temperature: args.fetch(:temperature),
          messages:
        }.to_json
      ).to_return(status: args.fetch(:response_status, 200), body: args.fetch(:response_body, body.to_json))
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
