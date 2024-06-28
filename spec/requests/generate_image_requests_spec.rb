require 'rails_helper'

RSpec.describe 'Generate image requests', type: :request do
  describe 'POST #create' do
    let(:user) { create :user }
    let(:prompt) { 'a dragon' }
    let(:negative_prompt) { 'a hobbit' }
    let(:image_name) { 'genimage_123' }
    let(:style) { GenerativeImage::Stability::STYLE_PRESETS.sample }
    let(:aspect_ratio) { GenerativeImage::Stability::CORE_ASPECT_RATIOS.sample }
    let(:params) { { generate_image_request: { prompt:, negative_prompt:, image_name:, style:, aspect_ratio: } } }
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
          expect { request }.to change(user.generate_image_requests
                                           .where(image_name:, options: { style:, aspect_ratio: }),
                                       :count).by(1)
        end

        it 'creates the prompt records' do
          request
          prompt_attrs = user.generate_image_requests.last.prompts.map do |p|
            p.attributes.slice('text', 'weight').symbolize_keys
          end
          expect(prompt_attrs).to contain_exactly({ text: prompt, weight: 1 }, { text: negative_prompt, weight: -1 })
        end

        it 'enqueues a GenerateImageJob' do
          request
          expect(GenerateImageJob).to have_received(:perform_async).with(user.generate_image_request_ids.last)
        end
      end

      context 'when the request is invalid' do
        let(:params) { { generate_image_request: { prompt:, image_name: nil } } }

        before { request }

        it 'returns unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it { is_expected.to have_turbo_stream(action: :update, target: 'alert-stream') }
      end
    end
  end
end
