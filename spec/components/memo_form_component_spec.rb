require 'rails_helper'

RSpec.describe MemoFormComponent, type: :component do
  subject { page }

  let(:memo) { build_stubbed(:memo, user:, conversation:) }
  let(:user) { build_stubbed :user }
  let(:conversation) { nil }
  let(:component) { described_class.new(memo:) }
  let(:wysiwyg_editor_component) do
    Class.new(ApplicationViewComponent) do
      haml_template <<~HAML
        WysiwygEditorComponent
      HAML
    end
  end
  let(:color_picker_component) do
    Class.new(ApplicationViewComponent) do
      haml_template <<~HAML
        ColorPickerComponent
      HAML
    end
  end

  before do
    stub_const('WysiwygEditorComponent', wysiwyg_editor_component)
    allow(WysiwygEditorComponent).to receive(:new).and_call_original

    stub_const('ColorPickerComponent', color_picker_component)
    allow(ColorPickerComponent).to receive(:new).and_call_original

    with_current_user(user) { render_inline(component) }
  end

  it { is_expected.to have_css "turbo-frame[id='memo_#{memo.id}']" }

  it { is_expected.to have_css "form[action='/users/#{user.id}/memos/#{memo.id}']" }

  it { is_expected.to have_css "button[type='submit']" }

  it { is_expected.to have_css "a.btn-secondary[href='#{user_memo_path(user, memo)}']" }

  it { is_expected.not_to have_css 'button[data-controller=\'modal-closer\']' }

  context 'when the memo is new' do
    let(:memo) {  Memo.new(user:) }

    it 'renders a modal closer' do
      expect(page).to have_css 'button[data-controller="modal-closer"]'
    end
  end

  context 'with a conversation exists' do
    let(:conversation) { build_stubbed :conversation }

    it 'sets the conversation ID dataset attribute' do
      expect(page).to have_css ".c-memo-form[data-conversation-id='#{conversation.id}']"
    end
  end

  it 'instantiates the WysiwygEditorComponent with the proper args' do
    expect(WysiwygEditorComponent).to have_received(:new).with(object: memo, method: :content)
  end

  it 'renders the WysiwygEditorComponent' do
    expect(page).to have_content 'WysiwygEditorComponent'
  end

  it 'instantiates the ColorPickerComponent with the proper args' do
    expected_args = {
      swatches: Memo::SWATCHES,
      selected_color: nil,
      align: :left,
      input_name: 'memo[color]'
    }
    expect(ColorPickerComponent).to have_received(:new).with(**expected_args)
  end

  it 'renders the ColorPicker' do
    expect(page).to have_content 'ColorPickerComponent'
  end

  context 'when the memo has a color' do
    let(:memo) { build_stubbed(:memo, :with_user, color: Memo::COLORS.sample) }

    it "sets the color picker's selected color property" do
      expected_args = {
        swatches: Memo::SWATCHES,
        selected_color: memo.color.hex,
        align: :left,
        input_name: 'memo[color]'
      }
      expect(ColorPickerComponent).to have_received(:new).with(**expected_args)
    end
  end

  it 'renders a cancel inline action' do
    within('.inline-action') do
      expect(page).to have_link I18n.t('cancel'), user_memo_path(user, memo)
    end
  end
end
