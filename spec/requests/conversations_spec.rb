require 'rails_helper'

RSpec.describe 'Conversations', type: :request do
  describe 'GET #index' do
    let(:user) { create :user }
    let!(:conversations) { create_list :conversation, 2, user: }
    let(:request) { get conversations_path, headers: }

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      it 'returns an OK response' do
        request
        expect(response).to have_http_status :ok
      end
    end

    context 'with JSON format' do
      let(:headers) { { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' } }
      let(:request) { get conversations_path, headers: }

      it_behaves_like 'an API authenticated route'

      it 'returns an OK response' do
        request
        expect(response).to have_http_status :ok
      end

      it 'returns an ordered list of conversations as json' do
        request
        expected_json = conversations.sort { |a, b| b.created_at <=> a.created_at }
                                     .map { _1.attributes.slice('id', 'created_at', 'updated_at') }.to_json
        expect(response.body).to eq expected_json
      end

      context 'when the conversation does not exist' do
        let(:conversations) { nil }

        it 'returns an empty array' do
          request
          expect(JSON.parse(response.body)).to eq []
        end
      end
    end
  end

  describe 'GET #new' do
    let(:user) { create :user, :with_setting }
    let(:request) { get new_conversation_path, headers: }
    let(:headers) { { 'ACCEPT' => 'text/html' } }

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'returns an OK response' do
      request
      expect(response).to have_http_status :ok
    end
  end

  describe 'POST #create' do
    subject { response }

    let(:user) { create :user, :with_setting }
    let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }
    let(:params) do
      {
        conversation: {
          temperature: 1,
          prompt: 'foo',
          text_id: 'gentext_1234',
          generate_text_preset_id: '',
          model: user.setting.text_model,
          turnable_type: 'GenerateTextRequest'
        }
      }
    end

    let(:request) { post conversations_path, headers:, params: }

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'has 303 response' do
      request
      expect(response).to have_http_status :see_other
    end

    it 'redirects to the conversation edit' do
      request
      expect(response).to redirect_to(edit_conversation_path(user.conversations.last))
    end

    it 'creates a conversation' do
      expect { request }.to change(user.conversations, :count).by(1)
    end

    it 'enqueus a GenerateTextJob' do
      allow(GenerateTextJob).to receive(:perform_async)
      request
      expect(GenerateTextJob).to have_received(:perform_async).with(user.generate_text_requests.last.id)
    end

    context 'with invalid params' do
      let(:params) do
        {
          conversation: {
            temperature: 1,
            prompt: nil,
            text_id: 'gentext_1234',
            generate_text_preset_id: '',
            model: user.setting.text_model,
            turnable_type: 'GenerateTextRequest'
          }
        }
      end

      before { request }

      it { is_expected.to have_http_status :unprocessable_entity }

      it 'shows the errors' do
        expect(response).to have_turbo_stream(action: 'update', target: 'alert-stream') do
          assert_select '.validation-errors'
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { create :user, :with_setting }
    let(:conversation) { create :conversation, user: }
    let(:request) { get edit_conversation_path(conversation), headers: }
    let(:headers) { { 'ACCEPT' => 'text/html' } }

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'returns an OK response' do
      request
      expect(response).to have_http_status :ok
    end
  end

  describe 'PUT #update' do
    subject { response }

    let(:user) { create :user, :with_setting }
    let(:conversation) { create :conversation, user: }
    let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }
    let(:title) { Faker::Lorem.sentence }
    let(:params) do
      {
        conversation: {
          title:,
          temperature: 1,
          prompt: 'foo',
          text_id: 'gentext_1234',
          generate_text_preset_id: '',
          model: user.setting.text_model,
          turnable_type: 'GenerateTextRequest'
        }
      }
    end

    let(:request) { put conversation_path(conversation), headers:, params: }

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'returns an OK response' do
      request
      expect(response).to have_http_status :ok
    end

    it 'updates the conversation' do
      expect { request }.to change { conversation.reload.title }.to title
    end

    it 'enqueus a GenerateTextJob' do
      allow(GenerateTextJob).to receive(:perform_async)
      request
      expect(GenerateTextJob).to have_received(:perform_async).with(user.generate_text_requests.last.id)
    end

    it 'renders the conversation title' do
      request
      expect(response).to have_turbo_stream(action: 'replace', target: 'conversation-title')
    end

    it 'render the conversation turn component' do
      request
      expect(response).to have_turbo_stream(action: 'append', target: 'conversation-turns') {
        assert_select '.c-conversation-turn'
      }
    end

    context 'with JSON format' do
      let(:request) { put conversation_path(conversation), headers:, params:, as: :json }
      let(:headers) { { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' } }

      before { request }

      it { is_expected.to have_http_status :ok }

      it 'returns the conversation JSON' do
        expect(JSON.parse(response.body)).to(
          eq conversation.reload.as_json(only: [:id, :memo_id, :created_at, :updated_at])
        )
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          conversation: {
            temperature: 1,
            prompt: nil,
            text_id: 'gentext_1234',
            generate_text_preset_id: '',
            model: user.setting.text_model,
            turnable_type: 'GenerateTextRequest'
          }
        }
      end

      before { request }

      it { is_expected.to have_http_status :unprocessable_entity }

      it 'shows the errors' do
        expect(response).to have_turbo_stream(action: 'update', target: 'alert-stream') {
          assert_select '.validation-errors'
        }
      end

      context 'with JSON format' do
        let(:request) { put conversation_path(conversation), headers:, params:, as: :json }
        let(:headers) { { 'ACCEPT' => 'application/json', 'Content-Type' => 'application/json' } }

        it { is_expected.to have_http_status :unprocessable_entity }

        it 'returns the conversation JSON' do
          request
          expect(JSON.parse(response.body)['error']).to eq 'message' => 'Prompt can\'t be blank'
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { response }

    let(:user) { create :user }
    let!(:conversation) { create :conversation, user: }
    let(:headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }
    let(:request) { delete conversation_path(conversation) }

    before do
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'returns an 302 response' do
      request
      expect(response).to have_http_status :found
    end

    it 'redirects to conversations index' do
      request
      expect(response).to redirect_to conversations_path
    end

    it 'deletes the conversation' do
      expect { request }.to change(user.conversations, :count).by(-1)
    end
  end
end
