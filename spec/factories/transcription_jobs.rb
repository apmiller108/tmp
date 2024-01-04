FactoryBot.define do
  factory :transcription_job do
    status { 'created' }
    association :active_storage_blob, :audio
    remote_job_id { Faker::Alphanumeric.alpha(number: 10) }

    trait :completed do
      status { TranscriptionJob.statuses[:completed] }
    end

    trait :with_transcription do
      transcription
    end
  end
end
