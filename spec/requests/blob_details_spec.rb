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
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'when the blob is associate to the user through a Memo' do
      before do
        memo.rich_text_content.embeds_blobs << blob
      end

      it 'returns an OK response' do
        request
        expect(response).to have_http_status :ok
      end

      context 'when the associated Memo does not belong to the user' do
        let(:memo) { create :memo }

        include_context 'with disable consider all requests local'

        it 'returns a 404 response' do
          request
          expect(response).to have_http_status :not_found
        end
      end
    end

    context 'when the blob is associated to a GenerateImageRequest' do
      let(:generate_image_request) { create :generate_image_request, user: }

      before do
        generate_image_request.image.udpate(image_blob: blob)
        blob.generate_image_request = generate_image_request
      end

      it 'returns an OK response' do
        request
        expect(response).to have_http_status :ok
      end

      context 'when the associated GenerateImageRequest does not belong to the user' do
        let(:generate_image_request) { create :generate_image_request }

        include_context 'with disable consider all requests local'

        it 'returns a 404 response' do
          request
          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
