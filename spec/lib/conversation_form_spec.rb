require 'rails_helper'

RSpec.describe ConversationForm, type: :model do
  let!(:user) { create(:user) }
  let!(:memo) { create(:memo, user:) }
  let!(:generate_text_request) { create(:generate_text_request, user:, text_id:, prompt:) }
  let(:text_id) { 'text_id' }
  let(:prompt) { 'this is a prompt' }
  let(:valid_params) do
    {
      assistant_response: 'Assistant response',
      text_id:,
      user:,
      memo_id: memo.id
    }
  end

  describe 'validations' do
    it 'is valid with valid parameters' do
      form = described_class.new(valid_params)
      expect(form).to be_valid
    end

    it 'is invalid without an assistant response' do
      form = described_class.new(valid_params.except(:assistant_response))
      expect(form).to be_invalid
      expect(form.errors[:assistant_response]).to include("can't be blank")
    end
  end

  describe '#save' do
    subject(:form) do
      described_class.new(valid_params)
    end

    it 'creates a conversation' do
      expect { form.save }.to change { Conversation.where(user:).count }.by(1)
      expect(form.generate_text_request.conversation).to eq(form.conversation)
    end

    it 'persists user prompt and assistant response' do
      form.save
      expect(user.conversations.last.exchange).to(
        eq [{ 'role' => 'user', 'content' => [{ 'type' => 'text', 'text' => prompt }] },
            { 'role' => 'assistant', 'content' => valid_params[:assistant_response] }]
      )
    end

    it 'associates the request to the conversation' do
      expect { form.save }.to change { generate_text_request.reload.conversation }
        .from(kind_of(NullConversation)).to(kind_of(Conversation))
    end

    it 'returns false if the form is invalid' do
      form = described_class.new(valid_params.except(:assistant_response))
      expect(form.save).to be false
    end
  end
end
