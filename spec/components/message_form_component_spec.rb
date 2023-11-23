require 'rails_helper'

RSpec.describe MessageFormComponent, type: :component do
  subject { page }

  let(:message) { build_stubbed(:message, :with_user) }
  let(:user) { message.user }
  let(:component) { described_class.new(message:) }

  class MockInlineFieldComponent < ApplicationViewComponent
    TEXT = 'MockInlineFieldComponent'
    renders_one :field_slot
    haml_template <<~HAML
      #{TEXT}
      = field_slot
    HAML
  end

  before do
    allow(InlineFieldComponent).to receive(:new).and_return(MockInlineFieldComponent.new)
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "form[action='/users/#{user.id}/messages/#{message.id}']" }

  it 'initializes the InlineFieldComponent with the proper arguments' do
    expect(InlineFieldComponent).to(
      have_received(:new)
        .with(model: [user, message], attribute: :content, form: kind_of(ActionView::Helpers::FormBuilder))
    )
  end

  it 'render the InlineFieldComponent' do
    expect(page).to have_text(MockInlineFieldComponent::TEXT)
  end

  it { is_expected.to have_css 'trix-editor[id="message_content"]' }
end
