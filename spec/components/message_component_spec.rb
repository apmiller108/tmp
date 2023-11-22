# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessageComponent, type: :component do
  let(:message) { build_stubbed(:message, :with_user) }
  let(:user) { message.user }
  let(:component) { described_class.new(message:) }

  before do
    with_current_user(user) { render_inline(component) }
  end

  it 'renders a link to edit the message' do
    expect(page).to have_link 'Edit Message'
  end
end
