FactoryBot.define do
  factory :action_text_rich_text, class: 'action_text/rich_text' do
    name { 'content' }
    body { ActionText::Content.new '<h1>Foo</h1>' }
  end
end
