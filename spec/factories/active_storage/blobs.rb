FactoryBot.define do
  factory :active_storage_blob, class: 'active_storage/blob' do
    filename { Rails.root.join('spec', 'attachment_samples', 'sample_cf24-30s.wav') }
    content_type { 'audio/wav' }
    byte_size { 5_000_000 }
  end
end
