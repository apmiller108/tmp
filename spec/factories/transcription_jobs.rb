FactoryBot.define do
  factory :transcription_job do
    status { 'created' }
    active_storage_blob { nil }
  end
end
