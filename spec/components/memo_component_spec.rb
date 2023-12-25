# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemoComponent, type: :component do
  subject { page }

  let(:memo) { build_stubbed(:memo, :with_user, content: memo_content) }
  let(:user) { memo.user }
  let(:memo_content) { Faker::Lorem.sentence }
  let(:component) { described_class.new(memo:) }

  before do
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='memo_#{memo.id}']" }

  it { is_expected.to have_link 'Edit Memo' }

  it { is_expected.to have_text memo_content }
end
