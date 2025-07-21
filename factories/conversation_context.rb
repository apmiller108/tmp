FactoryBot.define do
  factory :conversation_context do
    association :user
    file_ref { SecureRandom.uuid }
    filename { 'test_file.txt' }
    mime_type { 'text/plain' }
    context_type { 'file' }
  end
end
