FactoryBot.define do
  factory :user do
    email         { Faker::Internet.email }
    password      { User.random_password }
  end
end
