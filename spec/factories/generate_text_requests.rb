FactoryBot.define do
  factory :generate_text_request do
    text_id { Faker::Alphanumeric.alpha(number: 20) }
    prompt { Faker::Lorem.paragraph }
    temperature { 0.step(to: 1, by: 0.1).to_a.sample }
    model { GenerativeText::Anthropic::MODELS.values.sample.api_name }
    user

    trait :with_preset do
      generate_text_preset
    end

    trait :completed do
      status { 'completed' }
    end

    trait :in_progress do
      status { 'in_progress' }
    end

    trait :with_response do
      status { 'completed' }
      response do
        {
          'id' => 'msg_01DMcCdRr6gaWDuZs7Y63rhe',
          'type' => 'message',
          'role' => 'assistant',
          'content' => [{
            'type' => 'text',
            'text' => 'test response'
          }],
          'model' => 'claude-3-haiku-20240307',
          'stop_reason' => 'end_turn',
          'stop_sequence' => nil,
          'usage' => {
            'input_tokens' => 79, 'output_tokens' => 942
          }
        }
      end
    end
  end
end
