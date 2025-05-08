FactoryBot.define do
  factory :llm_tool do
    name { 'MyString' }
    description { 'MyText' }
    input_schema {}
    active { false }
  end
end
