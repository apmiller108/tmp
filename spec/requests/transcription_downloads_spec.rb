require 'rails_helper'

RSpec.describe 'Transcription Downloads', type: :request do
  describe 'GET #show' do
    subject { response }

    let(:request) { get "/users/#{user.id}/transcription_downloads/#{transcription.id}", headers: }
    let(:user) { create(:user) }
    let(:blob) { create :active_storage_blob, :audio }
    let(:memo) { create(:memo, user:) }
    let(:transcription_job) { create :transcription_job, active_storage_blob: blob }
    let(:transcription) { create(:transcription, transcription_job:, active_storage_blob: blob) }

    before do
      memo.rich_text_content.embeds_blobs << blob
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with HTML format' do
      let(:headers) { { 'ACCEPT' => 'text/html' } }

      it 'has OK status' do
        request
        expect(response).to have_http_status :ok
      end

      it 'sets the content disposition to attachment with the proper filename' do
        request
        expect(response.headers['Content-Disposition']).to(
          include("attachment; filename=\"transcription-#{transcription.active_storage_blob.filename}.txt\"")
        )
      end

      context 'when transcript does not belong to the user' do
        let(:memo) { create :memo, :with_user }

        include_context 'disable consider all requests local'

        it 'has not found status' do
          request
          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
