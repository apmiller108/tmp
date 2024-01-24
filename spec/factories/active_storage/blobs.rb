FactoryBot.define do
  factory :active_storage_blob, class: 'active_storage/blob' do
    filename { 'sample_cf24-30s.wav' }
    content_type { 'audio/wav' }
    checksum { 'checksum' }
    byte_size { 5_000_000 }

    trait :audio do
      content_type { 'audio/mp3' }
    end

    trait :image do
      content_type { 'image/png' }
    end
  end
end
