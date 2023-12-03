require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  subject { response }

  let(:user) { create :user }

  describe 'GET /index' do
    let(:request) { get "/users/#{user.id}/messages", headers: }
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
    let(:request) { get "/users/#{user.id}/messages/#{message.id}", headers: }
    let(:message) { create :message, user: }
    let(:headers) {}

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe 'GET /new' do
    let(:message) { create :message, user: }
    let(:request) { get "/users/#{user.id}/messages/new", headers: }
    let(:headers) {}

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
    end

    context 'with turbo stream format' do
      let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

      before { request }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to have_turbo_stream(action: 'prepend', target: 'messages') }
    end
  end

  describe 'POST /create' do
    let(:request) { post "/users/#{user.id}/messages", headers:, params: }
    let(:headers) {}
    let(:params) { { message: { content: '<div>Foo</div>' } } }

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with HTML format' do
      let(:headers) { { 'Accept' => 'text/html' } }
      let(:message) { Message.last }

      before { request }

      it { is_expected.to redirect_to user_message_path(user, message) }

      context 'when message is invalid' do
        let(:params) { { message: { content: '' } } }

        it { is_expected.to have_http_status :unprocessable_entity }
      end
    end

    context 'with turbo stream format' do
      subject { response }

      let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

      before { request }

      it { is_expected.to have_http_status :created }

      it 'renders the message component' do
        expect(response).to have_turbo_stream(action: 'replace', target: 'new_message') {
          assert_select 'div.c-message'
        }
      end

      context 'when message is invalid' do
        let(:params) { { message: { content: nil } } }

        it { is_expected.to have_http_status :unprocessable_entity }

        it 'renders the form with errors' do
          expect(response).to have_turbo_stream(action: 'replace', target: 'new_message') {
            assert_select '.c-message-form .form-errors'
          }
        end
      end
    end
  end

  describe 'GET /edit' do
    let(:request) { get "/users/#{user.id}/messages/#{message.id}/edit", headers: }
    let(:message) { create :message, user: }
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
    let(:request) { patch "/users/#{user.id}/messages/#{message.id}", headers:, params: }
    let(:message) { create :message, user: }
    let(:headers) {}
    let(:params) { { message: { content: '<div>Foo</div>' } } }

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with HTML format' do
      subject { response }

      let(:headers) { { 'ACCEPT' => 'text/html' } }

      before { request }

      it { is_expected.to redirect_to user_message_path(user, message) }

      context 'when message is invalid' do
        let(:params) { { message: { content: '' } } }

        it { is_expected.to have_http_status :unprocessable_entity }
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:message) { create :message, user: }
    let(:request) { delete "/users/#{user.id}/messages/#{message.id}", headers: }
    let(:headers) {}

    it_behaves_like 'an authenticated route'

    before { sign_in user }

    context 'with an HTML format' do
      before { request }

      it { is_expected.to redirect_to user_messages_path(user) }
    end

    context 'with a turbo stream format' do
      let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

      before { request }

      it { is_expected.to have_http_status :see_other }
      it { is_expected.to redirect_to user_messages_path(user) }

      context 'when the referrer is messages index' do
        let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html', 'Referer' => user_messages_url(user) } }
        it { is_expected.to have_http_status :ok }
        it { is_expected.to have_turbo_stream(action: 'remove', target: "message_#{message.id}") }
      end
    end
  end
end
