module GeminiHelpers
  def stub_gemini_generate_content_request(model:, response_status: 200, response_body: nil)
    response_body ||= {
      candidates: [
        {
          content: {
            parts: [{ text: 'Response' }]
          }
        }
      ],
      usageMetadata: { promptTokenCount: 10, candidatesTokenCount: 10 }
    }.to_json

    stub_request(:post, "#{Gemini::HOST}/#{Gemini::VERSION}/models/#{model.api_name}:generateContent")
      .with(query: hash_including(key: ENV.fetch('GEMINI_API_KEY')))
      .to_return(status: response_status, body: response_body)
  end

  def stub_gemini_stream_generate_content_request(model:, response_status: 200, response_body: nil)
    stub_request(:post, "#{Gemini::HOST}/#{Gemini::VERSION}/models/#{model.api_name}:streamGenerateContent")
      .with(query: hash_including(alt: 'sse', key: ENV.fetch('GEMINI_API_KEY')))
      .to_return(status: response_status, body: response_body)
  end
end

RSpec.configure do |config|
  config.include GeminiHelpers
end
