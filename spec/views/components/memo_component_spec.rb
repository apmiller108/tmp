# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemoComponent, type: :component do
  subject { page }

  let(:memo) { build_stubbed(:memo, :with_user, content: memo_content, color:) }
  let(:user) { memo.user }
  let(:memo_content) { Faker::Lorem.sentence }
  let(:color) { nil }
  let(:component) { described_class.new(memo:) }

  before do
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='memo_#{memo.id}']" }

  it { is_expected.to have_css "button[data-controller='modal-closer']" }

  it { is_expected.to have_css "a.edit-memo-link[href='#{edit_user_memo_path(user, memo)}']" }

  it { is_expected.to have_css "a.btn-danger[href='#{user_memo_path(user, memo)}'][data-turbo-method='delete']" }

  it { is_expected.to have_text memo_content }
end
