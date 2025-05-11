require 'rails_helper'

RSpec.describe ConversationForm do
  subject(:form) { described_class.new(attributes) }

  let(:attributes) { { user: } }
  let(:user) { create(:user, :with_setting) }
  let(:conversation) { form.conversation }
  let(:model) { GenerativeText::MODELS.sample.api_name }
  let(:title) { Faker::Lorem.sentence }
  let(:prompt) { Faker::Lorem.sentence }
  let(:temperature) { 0.7 }
  let!(:generate_text_preset) { create :generate_text_preset }
  let(:text_id) { 'gentext_1234' }

  describe '#save' do
    context 'with valid attributes' do
      let(:attributes) do
        {
          user:,
          title:,
          turnable_type: 'GenerateTextRequest',
          prompt:,
          temperature:,
          model:,
          generate_text_preset_id: generate_text_preset.id,
          text_id:
        }
      end

      it 'creates a conversation' do
        expect { form.save }.to change(Conversation.where(user:, title:), :count).by(1)
      end

      it 'creates a turn' do
        expect { form.save }.to change(conversation.turns, :count).by(1)
      end

      it 'creates a GenerateTextRequest' do
        form.save
        request = conversation.generate_text_requests.last
        expect(request.attributes.symbolize_keys).to(
          include(user_id: user.id, prompt:, temperature:, model:,
                  generate_text_preset_id: generate_text_preset.id, text_id:)
        )
      end

      it 'enqueues a generate job' do
        expect { form.save }.to change(GenerateTextJob.jobs, :size).by(1)
      end

      it 'returns true' do
        expect(form.save).to be true
      end
    end

    context 'with a conversation provided in the params' do
      let(:conversation) { create :conversation, user: }
      let(:attributes) do
        {
          user:,
          turnable_type: 'GenerateTextRequest',
          prompt:,
          temperature:,
          model:,
          text_id:,
          conversation:
        }
      end

      it 'creates a GenerateTextRequest' do
        form.save
        request = conversation.generate_text_requests.last
        expect(request.attributes.symbolize_keys).to(
          include(user_id: user.id, prompt:, temperature:, model:, text_id:)
        )
      end

      it 'enqueues a generate job' do
        expect { form.save }.to change(GenerateTextJob.jobs, :size).by(1)
      end

      it 'returns true' do
        expect(form.save).to be true
      end
    end

    context 'when a turnable_type is not provided' do
      let(:conversation) { create :conversation, user:, title: 'Foo' }
      let(:attributes) do
        {
          user:,
          title:,
          conversation:
        }
      end

      it 'only updates the conversation' do
        expect { form.save }.to change(conversation, :title).from('Foo').to(title)
      end

      it 'returns true' do
        expect(form.save).to be true
      end
    end

    context 'with invalid attributes' do
      let(:attributes) { { user: nil } }

      it 'returns false' do
        expect(form.save).to be false
      end

      it 'does not create a conversation' do
        expect { form.save }.not_to change(Conversation, :count)
      end
    end
  end

  describe '#turnable' do
    context 'with GenerateTextRequest type' do
      let(:attributes) do
        {
          user:,
          turnable_type: 'GenerateTextRequest',
          prompt: 'Test prompt'
        }
      end

      it 'returns a GenerateTextRequest instance' do
        expect(form.turnable).to be_a(GenerateTextRequest)
      end
    end

    context 'with GenerateImageRequest type' do
      let(:attributes) do
        {
          user:,
          turnable_type: 'GenerateImageRequest'
        }
      end

      it 'returns a GenerateImageRequest instance' do
        expect(form.turnable).to be_a(GenerateImageRequest)
      end
    end

    context 'without a turnable_type' do
      let(:attributes) do
        {
          user:
        }
      end

      it 'is nil' do
        expect(form.turnable).to be_nil
      end
    end
  end

  describe '#turn' do
    let(:attributes) do
      {
        user:,
        turnable_type: 'GenerateTextRequest',
        prompt: 'Test prompt'
      }
    end

    it 'returns a new turn for the conversation' do
      expect(form.turn).to be_a(ConversationTurn)
    end
  end

  describe 'default attributes' do
    context 'with existing conversation' do
      let(:existing_request) do
        create(:generate_text_request, temperature:, model:, generate_text_preset_id: generate_text_preset.id)
      end
      let!(:conversation_turn) { create(:conversation_turn, turnable: existing_request) }
      let(:conversation) { conversation_turn.conversation }
      let(:attributes) do
        {
          user:,
          conversation:
        }
      end

      it 'inherits settings from last request' do
        expect(form.attributes.symbolize_keys).to(
          include(model:, temperature:, generate_text_preset_id: generate_text_preset.id)
        )
      end
    end

    context 'when tool_types is nil' do
      let(:conversation) { build_stubbed :conversation, tool_types: ['image'] }
      let(:attributes) do
        {
          user:,
          conversation:
        }
      end

      it 'sets tool_types to what is already set on the conversation' do
        expect(form.attributes).to include('tool_types' => conversation.tool_types)
      end
    end

    context 'when tool_types is provided' do
      let(:conversation) { build_stubbed :conversation, tool_types: 'image' }
      let(:attributes) do
        {
          user:,
          conversation:,
          tool_types: 'test1 test2'
        }
      end

      it 'sets tool_types to the parsed provided value' do
        expect(form.attributes).to include('tool_types' => %w[test1 test2])
      end
    end

    context 'with new conversation and prompt' do
      let(:attributes) do
        {
          user:,
          prompt: 'Test prompt'
        }
      end

      it 'sets default title from prompt' do
        expect(form.title).not_to be_nil
      end
    end
  end
end
