FactoryBot.define do
  factory :transcription do
    association :active_storage_blob, :audio
    content { Faker::Lorem.paragraph }
    association :transcription_job

    trait :with_summary do
      summary
    end
  end
end
