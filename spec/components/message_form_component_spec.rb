require 'rails_helper'

RSpec.describe MessageFormComponent, type: :component do
  subject { page }

  let(:message) { build_stubbed(:message, :with_user) }
  let(:user) { message.user }
  let(:component) { described_class.new(message:) }

  before do
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='message_#{message.id}']" }

  it { is_expected.to have_css "form[action='/users/#{user.id}/messages/#{message.id}']" }

  it { is_expected.to have_css 'trix-editor[id="message_content"]' }

  it 'renders a cancel inline action' do
    within('.inline-action') do
      expect(subject).to have_link I18n.t('cancel'), user_message_path(user, message)
    end
  end
end
