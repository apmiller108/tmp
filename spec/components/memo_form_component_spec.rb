require 'rails_helper'

RSpec.describe MemoFormComponent, type: :component do
  subject { page }

  let(:memo) { build_stubbed(:memo, :with_user) }
  let(:user) { memo.user }
  let(:component) { described_class.new(memo:) }
  let(:wysiwyg_editor_component) do
    Class.new(ApplicationViewComponent) do
      haml_template <<~HAML
        WysiwygEditorComponent
      HAML
    end
  end

  before do
    stub_const('WysiwygEditorComponent', wysiwyg_editor_component)
    allow(WysiwygEditorComponent).to receive(:new).and_call_original
    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='memo_#{memo.id}']" }

  it { is_expected.to have_css "form[action='/users/#{user.id}/memos/#{memo.id}']" }

  it 'instantiates the WysiwygEditorComponent with the proper args' do
    expect(WysiwygEditorComponent).to have_received(:new).with(object: memo, method: :content)
  end

  it 'renders the WysiwygEditorComponent' do
    expect(page).to have_content 'WysiwygEditorComponent'
  end

  it 'renders a cancel inline action' do
    within('.inline-action') do
      expect(page).to have_link I18n.t('cancel'), user_memo_path(user, memo)
    end
  end
end
