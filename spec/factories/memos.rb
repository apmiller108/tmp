FactoryBot.define do
  factory :memo do
    title { Faker::DcComics.title }
    content { '<h1>Content</h1>' }
    color { nil }
    user

    trait :with_user do
      user
    end
  end
end
