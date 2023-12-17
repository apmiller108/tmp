FactoryBot.define do
  factory :active_storage_attachment, class: 'active_storage/attachment' do
    name { 'embeds' }
    blob factory: :active_storage_blob
  end
end
