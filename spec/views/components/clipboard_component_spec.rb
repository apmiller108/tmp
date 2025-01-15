require 'rails_helper'

RSpec.describe ClipboardComponent, type: :component do
  subject { page }

  before do
    render_inline(
      described_class.new(css_class: 'my-clipboard').tap do |c|
        c.with_copyable { '<input type="text" name="copyable"></input>'.html_safe }
      end
    )
  end

  it { is_expected.to have_css '.c-clipboard.my-clipboard[data-controller="clipboard"]' }
  it { is_expected.to have_css 'button.copy-btn' }
  it { is_expected.to have_css 'input[name="copyable"]' }
  it { is_expected.to have_css '.bi.bi-copy[data-clipboard-target="copyIcon"]' }
  it { is_expected.to have_css '.bi.bi-check2-square[data-clipboard-target="successIcon"]' }
end
