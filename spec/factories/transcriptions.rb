FactoryBot.define do
  factory :transcription do
    active_storage_blob { nil }
    content { "MyText" }
    transcription_job { nil }
  end
end
