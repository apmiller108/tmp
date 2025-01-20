require 'rails_helper'

RSpec.describe 'Generate text presets', type: :request do
  let(:user) { create(:user) }
  let(:preset) { create(:generate_text_preset, user:) }

  before { sign_in user }

  describe 'GET #index' do
    let(:request) { get generate_text_presets_path }

    it_behaves_like 'an authenticated route'

    it 'returns http success' do
      request
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    let(:request) { get new_generate_text_preset_path }

    it_behaves_like 'an authenticated route'

    it 'returns http success' do
      request
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:params) do
      {
        generate_text_preset: {
          name: 'Test Preset',
          description: 'Test Description',
          system_message: 'Test Message',
          temperature: 0.7
        }
      }
    end
    let(:request) { post generate_text_presets_path, params:, as: :turbo_stream }

    it_behaves_like 'an authenticated route'

    it 'creates a new preset' do
      expect { request }.to change(user.generate_text_presets, :count).by(1)
    end

    it 'redirects to index page' do
      request
      expect(response).to redirect_to(generate_text_presets_path)
    end

    context 'with redirect_after_create parameter' do
      let(:params) do
        {
          generate_text_preset: {
            name: 'Test Preset',
            description: 'Test Description',
            system_message: 'Test Message',
            temperature: 0.7
          },
          redirect_after_create: '/some_path'
        }
      end

      it 'redirects to specified path' do
        request
        preset = user.generate_text_presets.last
        expect(response).to redirect_to(%r{/some_path\?text_preset_id=#{preset.id}})
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        { generate_text_preset: { name: '' } }
      end

      it 'returns unprocessable entity status' do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates the flash message' do
        request
        expect(response).to have_turbo_stream(action: 'update', target: FlashMessageComponent::ID)
      end
    end
  end

  describe 'GET #edit' do
    let(:request) { get edit_generate_text_preset_path(preset) }

    it_behaves_like 'an authenticated route'

    it 'returns http success' do
      request
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:params) { { generate_text_preset: { name: 'Updated Name' } } }
    let(:request) { patch generate_text_preset_path(preset), params:, as: :turbo_stream }

    it_behaves_like 'an authenticated route'

    it 'updates the preset' do
      request
      preset.reload
      expect(preset.name).to eq('Updated Name')
    end

    it 'redirects to index page' do
      request
      expect(response).to redirect_to(generate_text_presets_path)
    end

    context 'with invalid parameters' do
      let(:params) { { generate_text_preset: { name: '' } } }

      it 'returns unprocessable entity status' do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates the flash message' do
        request
        expect(response).to have_turbo_stream(action: 'update', target: FlashMessageComponent::ID)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:preset) { create(:generate_text_preset, user:) }
    let(:request) { delete generate_text_preset_path(preset), as: :turbo_stream }

    it_behaves_like 'an authenticated route'

    it 'deletes the preset' do
      expect { request }.to change(GenerateTextPreset, :count).by(-1)
    end

    it 'returns successful response' do
      request
      expect(response).to be_successful
    end

    it 'returns a turbo stream remove action' do
      request
      expect(response).to have_turbo_stream(action: 'remove', target: "generate_text_preset_#{preset.id}")
    end
  end
end
