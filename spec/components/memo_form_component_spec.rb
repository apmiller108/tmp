require 'rails_helper'

RSpec.describe MemoFormComponent, type: :component do
  subject { page }

  let(:memo) { build_stubbed(:memo, :with_user) }
  let(:user) { memo.user }
  let(:component) { described_class.new(memo:) }

  before do
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='memo_#{memo.id}']" }

  it { is_expected.to have_css "form[action='/users/#{user.id}/memos/#{memo.id}']" }

  it { is_expected.to have_css 'trix-editor[id="memo_content"]' }

  it 'renders a cancel inline action' do
    within('.inline-action') do
      expect(page).to have_link I18n.t('cancel'), user_memo_path(user, memo)
    end
  end
end
