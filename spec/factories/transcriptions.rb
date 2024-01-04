FactoryBot.define do
  factory :transcription do
    association :active_storage_blob, :audio
    content { Faker::Lorem.paragraph }
    association :transcription_job

    trait :with_blob do
      active_storage_blob
    end
  end
end
