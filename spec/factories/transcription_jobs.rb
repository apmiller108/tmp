FactoryBot.define do
  factory :transcription_job do
    status { 'created' }
    active_storage_blob { nil }

    trait :with_transcription do
      transcription
    end

    trait :with_blob do
      active_storage_blob
    end
  end
end
