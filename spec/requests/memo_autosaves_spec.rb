require 'rails_helper'

RSpec.describe 'Memo autostaves', type: :request do
  let(:user) { create(:user) }
  let(:params) { { memo: { content: 'Test memo', title: 'Test title', color: Memo::COLORS.sample } } }

  before do
    sign_in user
  end

  describe 'POST #create' do
    subject { response }

    let(:request) do
      post memos_autosaves_path, params:, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    end

    it_behaves_like 'an authenticated route'

    context 'with valid params' do
      before { request }

      it { is_expected.to have_http_status(:created) }
      it { is_expected.to have_turbo_stream(action: 'replace', target: 'new_memo') }
      it { is_expected.to have_turbo_stream(action: 'prepend', target: 'memos') }
    end

    context 'with invalid params' do
      let(:params) { { memo: { content: 'Test memo', title: nil, color: Memo::COLORS.sample } } }

      before { request }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end

  describe 'PATCH #update' do
    subject { response }

    let(:memo) { create :memo, user: }

    let(:request) do
      patch "/memos/autosaves/#{memo.id}", params:, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    end

    it_behaves_like 'an authenticated route'

    context 'with valid params' do
      before { request }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to have_turbo_stream(action: 'replace', target: "card_memo_#{memo.id}") }
    end

    context 'with invalid params' do
      let(:params) { { memo: { content: 'Test memo', title: nil, color: Memo::COLORS.sample } } }

      before { request }

      it { is_expected.to have_http_status(:unprocessable_entity) }
    end
  end
end
