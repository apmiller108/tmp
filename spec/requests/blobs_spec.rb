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
      memo.rich_text_content.embeds_blobs << blob
      sign_in user
    end

    it_behaves_like 'an authenticated route'

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
end
