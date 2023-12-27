FactoryBot.define do
  factory :transcription do
    active_storage_blob { nil }
    content { Faker::Lorem.paragraph }
    transcription_job { nil }
  end
end
