require 'rails_helper'

RSpec.describe 'Blobs', type: :request do
  describe 'GET #show' do
    subject { response }

    let(:request) { get "/blobs/#{blob.id}", headers: }
    let(:user) { create :user }
    let(:memo) { create :memo, user: }
    let(:io) { File.open Rails.root.join('spec/fixtures/files/image.png') }
    let(:blob) { ActiveStorage::Blob.create_and_upload!(io:, filename: 'image.png') }
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

      it 'sets the content disposition to attachment with the proper filename' do
        request
        expect(response.headers['Content-Disposition']).to(
          include("attachment; filename=\"#{blob.filename}\"")
        )
      end

      context 'when the associated memo does not belong to the user' do
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
      let(:blob) { generate_image_request.image_blob }

      before do
        generate_image_request.image.attach(io:, content_type: 'image/png', filename: 'image.png')
        blob.generate_image_request = generate_image_request
      end

      it 'returns an OK response' do
        request
        expect(response).to have_http_status :ok
      end

      it 'sets the content disposition to attachment with the proper filename' do
        request
        expect(response.headers['Content-Disposition']).to(
          include("attachment; filename=\"#{blob.filename}\"")
        )
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
