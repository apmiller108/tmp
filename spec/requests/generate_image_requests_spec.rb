require 'rails_helper'

RSpec.describe 'Generate image requests', type: :request do
  describe 'POST #create' do
    let(:user) { create :user }
    let(:prompts) { [{ text: 'a dragon', weight: 1 }, { text: 'cave', weight: -1 }] }
    let(:image_id) { 'foo123' }
    let(:style) { GenerativeImage::Stability::STYLE_PRESETS.sample }
    let(:dimensions) { GenerativeImage::Stability::DIMENSIONS.sample }
    let(:params) { { generate_image_request: { prompts:, image_id:, style:, dimensions: } } }
    let(:request) do
      post generate_image_requests_path, params:, as: :turbo_stream
    end

    before do
      allow(GenerateImageJob).to receive(:perform_async)
      sign_in user
    end

    it_behaves_like 'an authenticated route'

    context 'with a turbo stream format' do
      context 'when the request is valid response' do
        it 'returns a successful response' do
          request
          expect(response).to have_http_status(:created)
        end

        it 'renders the turbo stream with generated content' do
          request
          expect(response.body).to be_empty
        end

        it 'creates a generate_image_requests record' do
          expect { request }.to change(user.generate_image_requests.where(image_id:, style:, dimensions:), :count).by(1)
        end

        it 'creates the prompt records' do
          request
          prompt_attrs = user.generate_image_requests.last.prompts.pluck(:text, :weight)
          expect(prompt_attrs).to contain_exactly(*prompts.map(&:values))
        end

        it 'enqueues a GenerateImageJob' do
          request
          expect(GenerateImageJob).to have_received(:perform_async).with(user.generate_image_request_ids.last)
        end
      end

      context 'when the request is invalid' do
        let(:params) { { generate_image_request: { prompts:, image_id: nil } } }

        before { request }

        it 'returns unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it { is_expected.to have_turbo_stream(action: :update, target: 'alert-stream') }
      end
    end
  end
end
