FactoryBot.define do
  factory :conversation do
    title { Faker::Lorem.sentence }
    user

    trait :with_requests do
      transient do
        request_count { 3 }
      end

      generate_text_requests do
        Array.new(request_count) { association(:generate_text_request, :with_response) }
      end
    end
  end
end
