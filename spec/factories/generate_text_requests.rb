FactoryBot.define do
  factory :generate_text_request do
    text_id { Faker::Alphanumeric.alpha(number: 20) }
    prompt { Faker::Lorem.paragraph }
    temperature { GenerateTextRequest::TEMPERATURE_VALUES.sample }
    model { GenerativeText::MODELS.sample.api_name }
    user

    trait :with_anthropic_model do
      model { GenerativeText::Anthropic::MODELS.sample.api_name }
    end

    trait :with_aws_model do
      model { GenerativeText::AWS::MODELS.sample.api_name }
    end

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
      model { GenerativeText::Anthropic::MODELS.sample.api_name }
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
            'input_tokens' => 79,
            'output_tokens' => 942,
            'cache_creation_input_tokens' => 0,
            'cache_read_input_tokens' => 0
          }
        }
      end
    end
  end
end
