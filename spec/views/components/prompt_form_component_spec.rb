# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptFormComponent, type: :component do
  subject(:component) { described_class.new(conversation_form:, **opts) }

  let(:user) { build_stubbed(:user, setting:) }
  let(:setting) { build_stubbed(:setting) }
  let(:conversation) { build_stubbed(:conversation, user:) }
  let(:conversation_form) { ConversationForm.new conversation:, user: }
  let(:token_count) { 99 }
  let(:opts) { {} }

  before do
    allow(conversation).to receive(:token_count).and_return token_count
  end

  it 'shows the token count' do
    with_current_user(user) { render_inline component }
    expect(page).to have_css '.token-display', text: /Tokens:\s+#{token_count}/
  end

  describe '#id' do
    it 'returns prompt-form' do
      with_current_user(user) { render_inline component }
      expect(component.id).to eq('prompt-form')
    end
  end

  describe '#disabled?' do
    before do
      with_current_user(user) { render_inline component }
    end

    context 'when disabled is true' do
      let(:opts) { { disabled: true } }

      it 'disables the submit button' do
        expect(page).to have_css 'button[type="submit"][disabled="disabled"]'
      end
    end

    context 'when disabled is false' do
      let(:opts) { { disabled: false } }

      it 'does not disable the submit button' do
        expect(page).not_to have_css 'button[type="submit"][disabled="disabled"]'
      end
    end
  end

  describe 'initial form values' do
    context 'with no previous requests' do
      before do
        with_current_user(user) { render_inline component }
      end

      it 'sets the model to the users setting model' do
        model_name = GenerativeText::MODELS.find { _1.api_name == setting.text_model }.name
        expect(page).to have_select 'conversation_model', selected: model_name
      end
    end

    context 'with previous completed request' do
      let(:model) { GenerativeText.active_models.sample }
      let(:temperature) { '0.7' }
      let!(:preset) { create :generate_text_preset }
      let(:generate_text_requests) { GenerateTextRequest.none }

      let(:previous_request) do
        build_stubbed(:generate_text_request,
                      model: model.api_name,
                      temperature:,
                      generate_text_preset_id: preset.id,
                      status: :completed)
      end

      before do
        allow(conversation).to receive(:generate_text_requests).and_return(generate_text_requests)
        allow(generate_text_requests).to receive(:last).and_return previous_request
        with_current_user(user) { render_inline component }
      end

      it 'sets the selected model to the previously completed request\'s model' do
        expect(page).to have_select 'conversation_model', selected: model.name
      end

      it 'sets the preset to the previously completed request\'s prest' do
        expect(page).to have_select 'conversation_generate_text_preset_id', selected: preset.name
      end

      it 'sets the temp to the previously completed request\'s temp' do
        expect(page).to have_field 'conversation_temperature', with: temperature
      end
    end
  end
end
