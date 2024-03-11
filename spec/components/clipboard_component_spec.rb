require 'rails_helper'

RSpec.describe ClipboardComponent, type: :component do
  subject { page }

  before do
    render_inline(described_class.new('my-clipboard') { |c| c.with_copyable { '<input type="text"></input>'} })
  end

  it { is_expected.to have_css '.c-clipboard.my-clipboard[data-controller="clipboard"]'}
  it { is_expected.to have_css 'button.copy-btn' }
  it { is_expected.to have_css 'input[type="text"]' }
end
