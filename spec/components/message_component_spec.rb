# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessageComponent, type: :component do
  subject { page }
  let(:message) { build_stubbed(:message, :with_user, content: message_content) }
  let(:user) { message.user }
  let(:message_content) { Faker::Lorem.sentence }
  let(:component) { described_class.new(message:) }

  before do
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='message_#{message.id}']" }

  it { is_expected.to have_link 'Edit Message' }

  it { is_expected.to have_text message_content }
end
