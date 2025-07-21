require 'rails_helper'

RSpec.describe ConversationContext, type: :model do
  describe '.create_for!' do
    let(:user) { create(:user) }
    let(:file_response) do
      instance_double(
        Anthropic::FileResponse,
        id: 'file_id_123',
        filename: 'document.pdf',
        mime_type: 'application/pdf'
      )
    end

    context 'when creation is successful' do
      subject(:created_context) { described_class.create_for!(user, file_response) }

      it 'creates a new ConversationContext record' do
        expect { created_context }.to change(described_class, :count).by(1)
      end

      it 'sets the correct attributes for the new record' do
        expect(created_context).to have_attributes(
          user:,
          file_ref: 'file_id_123',
          filename: 'document.pdf',
          mime_type: 'application/pdf',
          context_type: 'file'
        )
      end
    end

    context 'when an error occurs during creation' do
      before do
        allow(described_class).to receive(:create!).and_raise(StandardError, 'Database error')
      end

      it 'raises a CreateError' do
        expect do
          described_class.create_for!(user, file_response)
        end.to raise_error(ConversationContext::CreateError)
      end
    end
  end

  describe '#to_content_block' do
    subject(:content_block) { context.to_content_block }

    let(:context) do
      build_stubbed(
        :conversation_context,
        file_ref: 'file_id_456',
        filename: 'report.txt',
        mime_type:
      )
    end

    context 'when mime_type is a document type (e.g., text/plain)' do
      let(:mime_type) { 'text/plain' }

      it 'returns a content block with document type and title metadata' do
        expect(content_block).to eq(
          type: 'document',
          source: {
            type: 'file',
            file_id: 'file_id_456'
          },
          title: 'report.txt'
        )
      end
    end

    context 'when mime_type is an image type (e.g., image/jpeg)' do
      let(:mime_type) { 'image/jpeg' }

      it 'returns a content block with image type and empty metadata' do
        expect(content_block).to eq(
          type: 'image',
          source: {
            type: 'file',
            file_id: 'file_id_456'
          }
        )
      end
    end

    context 'when mime_type is an unknown type' do
      let(:mime_type) { 'application/octet-stream' }

      it 'returns a content block with default type and empty metadata' do
        expect(content_block).to eq(
          type: 'container_upload',
          source: {
            type: 'file',
            file_id: 'file_id_456'
          }
        )
      end
    end
  end
end
