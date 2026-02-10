FactoryBot.define do
  factory :conversation_context do
    sequence(:file_ref) { |n| "file_#{n}" }
    filename { Faker::File.file_name }
    mime_type { 'application/pdf' }
    context_type { 'file' }
    vendor { :anthropic }
    user
  end
end
