FactoryBot.define do
  factory :conversation do
    exchange do
      [{ 'role' => 'user', 'content' => [{ 'text' => 'test', 'type' => 'text' }] },
       { 'role' => 'assistant', 'content' => "I'm here! How can I assist you today?" }]
    end
  end
end
