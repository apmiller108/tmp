# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemoCardComponent, type: :component do
  subject { page }

  let(:memo) { build_stubbed(:memo, user:, title: 'Test Memo', content: '<h1>Lorem ipsum</h1>') }
  let(:user) { build_stubbed :user }
  let(:component) { described_class.new(memo:) }

  before do
    with_current_user(user) do
      render_inline component
    end
  end

  it 'is a modal opener' do
    expect(page).to have_css ".c-memo-card[data-controller='modal-opener memo-card']"\
                             "[data-modal='#{ModalComponent.id}']"\
                             "[data-modal-src='#{user_memo_path(user, memo)}']"
  end

  it { is_expected.to have_css '.card-title', text: memo.title }
  it { is_expected.to have_css '.card-subtitle', text: /Created.*ago/ }
  it { is_expected.to have_css '.card-subtitle', text: /Updated.*ago/ }
  it { is_expected.to have_css '.card-text', text: memo.content.to_plain_text }
end
