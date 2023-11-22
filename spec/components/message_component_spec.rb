# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessageComponent, type: :component do
  subject { page }
  let(:message) { build_stubbed(:message, :with_user, content: message_content) }
  let(:user) { message.user }
  let(:message_content) { Faker::Lorem.sentence }
  let(:component) { described_class.new(message:) }
  class MockInlineEditComponent < ApplicationViewComponent
    TEXT = 'InlineEditComponent'
    renders_one :field_slot
    haml_template <<~HAML
      #{TEXT}
      = field_slot
    HAML
  end

  before do
    allow(InlineEditComponent).to receive(:new).and_return(MockInlineEditComponent.new)
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_link 'Edit Message' }

  it 'instantiates the InlineEditComponent with the proper args' do
    expect(InlineEditComponent).to have_received(:new).with(model: [user, message], attribute: :content)
  end

  it 'renders the InlineEditComponent' do
    expect(page).to have_text(MockInlineEditComponent::TEXT)
  end

  it { is_expected.to have_text message_content }
end
