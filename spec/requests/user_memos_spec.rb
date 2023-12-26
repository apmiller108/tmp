require 'rails_helper'

RSpec.describe 'Memos', type: :request do
  subject { response }

  let(:user) { create :user }

  describe 'GET /index' do
    let(:request) { get "/users/#{user.id}/memos", headers: }
    let(:headers) {}

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to have_http_status :ok }
    end
  end

  describe 'GET /show' do
    let(:request) { get "/users/#{user.id}/memos/#{memo.id}", headers: }
    let(:memo) { create :memo, user: }
    let(:headers) {}

    before { sign_in user }

    it_behaves_like 'an authenticated route'

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe 'GET /new' do
    let(:memo) { create :memo, user: }
    let(:request) { get "/users/#{user.id}/memos/new", headers: }
    let(:headers) {}

    before { sign_in user }

    it_behaves_like 'an authenticated route'

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
    end

    context 'with turbo stream format' do
      let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to have_turbo_stream(action: 'prepend', target: 'memos') }
    end
  end

  describe 'POST /create' do
    let(:request) { post "/users/#{user.id}/memos", headers:, params: }
    let(:headers) {}
    let(:params) { { memo: { content: '<div>Foo</div>' } } }

    before do
      allow(TranscribableContentHandlerJob).to receive(:perform_async)
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with HTML format' do
      let(:headers) { { 'Accept' => 'text/html' } }
      let(:memo) { Memo.last }

      before { request }

      it { is_expected.to redirect_to user_memo_path(user, memo) }

      it 'enqueues a TranscribableContentHandlerJob' do
        expect(TranscribableContentHandlerJob).to have_received(:perform_async).with(memo.id)
      end

      context 'when memo is invalid' do
        let(:params) { { memo: { content: '' } } }

        it { is_expected.to have_http_status :unprocessable_entity }

        it 'does not enqueue a TranscribableContentHandlerJob' do
          expect(TranscribableContentHandlerJob).not_to have_received(:perform_async)
        end
      end
    end

    context 'with turbo stream format' do
      subject { response }

      let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }
      let(:memo) { Memo.last }

      before { request }

      it { is_expected.to have_http_status :created }

      it 'renders the memo component' do
        expect(response).to have_turbo_stream(action: 'replace', target: 'new_memo') {
          assert_select 'div.c-memo'
        }
      end

      it 'enqueues a TranscribableContentHandlerJob' do
        expect(TranscribableContentHandlerJob).to have_received(:perform_async).with(memo.id)
      end

      context 'when memo is invalid' do
        let(:params) { { memo: { content: nil } } }

        it { is_expected.to have_http_status :unprocessable_entity }

        it 'renders the form with errors' do
          expect(response).to have_turbo_stream(action: 'replace', target: 'new_memo') {
            assert_select '.c-memo-form .form-errors'
          }
        end

        it 'does not enqueue a TranscribableContentHandlerJob' do
          expect(TranscribableContentHandlerJob).not_to have_received(:perform_async)
        end
      end
    end
  end

  describe 'GET /edit' do
    let(:request) { get "/users/#{user.id}/memos/#{memo.id}/edit", headers: }
    let(:memo) { create :memo, user: }
    let(:headers) {}

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe 'PATCH /update' do
    let(:request) { patch "/users/#{user.id}/memos/#{memo.id}", headers:, params: }
    let(:memo) { create :memo, user: }
    let(:headers) {}
    let(:params) { { memo: { content: '<div>Foo</div>' } } }

    before do
      allow(TranscribableContentHandlerJob).to receive(:perform_async)
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with HTML format' do
      subject { response }

      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to redirect_to user_memo_path(user, memo) }

      it 'enqueues a TranscribableContentHandlerJob' do
        expect(TranscribableContentHandlerJob).to have_received(:perform_async).with(memo.id)
      end

      context 'when memo is invalid' do
        let(:params) { { memo: { content: '' } } }

        it { is_expected.to have_http_status :unprocessable_entity }

        it 'does not enqueue a TranscribableContentHandlerJob' do
          expect(TranscribableContentHandlerJob).not_to have_received(:perform_async)
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:memo) { create :memo, user: }
    let(:request) { delete "/users/#{user.id}/memos/#{memo.id}", headers: }
    let(:headers) {}

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with an HTML format' do
      before { request }

      it { is_expected.to redirect_to user_memos_path(user) }
    end

    context 'with a turbo stream format' do
      let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

      before { request }

      it { is_expected.to have_http_status :see_other }
      it { is_expected.to redirect_to user_memos_path(user) }

      context 'when the referrer is memos index' do
        let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html', 'Referer' => user_memos_url(user) } }
        it { is_expected.to have_http_status :ok }
        it { is_expected.to have_turbo_stream(action: 'remove', target: "memo_#{memo.id}") }
      end
    end
  end
end
