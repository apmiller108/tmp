require 'rails_helper'

RSpec.describe 'Blob Details', type: :request do
  describe 'GET #show' do
    subject { response }

    let(:request) { get "/blob_details/#{blob.id}", headers: }
    let(:user) { create :user }
    let(:memo) { create :memo, user: }
    let(:blob) { create :active_storage_blob }
    let(:headers) { { 'ACCEPT' => 'text/html' } }

    before do
      memo.rich_text_content.embeds_blobs << blob
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    it 'returns an OK response' do
      request
      expect(response).to have_http_status :ok
    end

    context 'when the associated memo does not belong to the user' do
      let(:memo) { create :memo }

      include_context 'disable consider all requests local'

      it 'returns a 404 response' do
        request
        expect(response).to have_http_status :not_found
      end
    end
  end
end
