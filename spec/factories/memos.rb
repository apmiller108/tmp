FactoryBot.define do
  factory :memo do
    title { Faker::DcComics.title }
    content { '<h1>Content</h1>' }
    color { nil }
    audio_attachment_count { 0 }
    image_attachment_count { 0 }
    video_attachment_count { 0 }
    attachment_count { 0 }
    user

    trait :with_user do
      user
    end
  end
end
