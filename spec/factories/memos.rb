FactoryBot.define do
  factory :memo do
    title { Faker::DcComics.title }
    content { '<h1>Content</h1>' }
    color { nil }
    audio_attachment_count { 1 }
    image_attachment_count { 2 }
    video_attachment_count { 3 }
    attachment_count { 6 }
    user

    trait :with_user do
      user
    end
  end
end
