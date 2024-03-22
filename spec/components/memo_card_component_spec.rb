# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemoCardComponent, type: :component do
  subject { page }

  let(:memo) do
    build_stubbed(:memo, user:, title: 'Test Memo', rich_text_content:)
  end
  let(:plain_text_body) { 'Lorem ipsum' }
  let(:rich_text_content) do
    build_stubbed(:action_text_rich_text, body: '<h1>Lorem ipsum</h1>', plain_text_body:)
  end
  let(:blob) { build_stubbed(:active_storage_blob, content_type: 'image/png') }
  let(:user) { build_stubbed :user }
  let(:component) { described_class.new(memo:) }
  let(:attachment_icon_component) do
    Class.new(ApplicationViewComponent) do
      haml_template 'ATTACHMENT_ICON_COMPONENT'
    end
  end

  before do
    stub_const('AttachmentIconComponent', attachment_icon_component)
    allow(AttachmentIconComponent).to receive(:new).and_call_original
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
  it { is_expected.to have_css '.card-text', text: plain_text_body }

  context 'with a plain text attchment representation' do
    let(:plain_text_body) { 'Foo %JSON{{{"id": 1, "content_type": "image/png","filename": "filename123"}}} Bar' }

    it 'instantiates an AttachmentIconComponent' do
      expect(AttachmentIconComponent).to have_received(:new).with(blob_id: 1, content_type: 'image/png')
    end
  end
end
