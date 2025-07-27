require 'rails_helper'

RSpec.describe Anthropic::FileResponse do
  describe '.for' do
    context 'when given a single hash' do
      let(:data) do
        {
          'id' => 'file_abc123',
          'type' => 'file',
          'filename' => 'document.pdf',
          'mime_type' => 'application/pdf',
          'size_bytes' => 12345,
          'created_at' => '2023-01-01T12:00:00Z'
        }
      end

      it 'returns a single FileResponse object' do
        file_response = described_class.for(data)
        expect(file_response).to be_an_instance_of(Anthropic::FileResponse)
      end

      it 'has the proper attributes' do
        file_response = described_class.for(data)
        expect(file_response.attributes.symbolize_keys).to(
          eq(
            {
              id: 'file_abc123',
              type: 'file',
              filename: 'document.pdf',
              mime_type: 'application/pdf',
              size_bytes: 12_345,
              created_at: Time.parse('2023-01-01T12:00:00Z'),
              downloadable: false
            }
          )
        )
      end
    end

    context 'when given a hash with a data array' do
      let(:data) do
        {
          'data' => [
            {
              'id' => 'file_abc123',
              'type' => 'file',
              'filename' => 'document1.pdf',
              'mime_type' => 'application/pdf',
              'size_bytes' => 1000,
              'created_at' => '2023-01-01T12:00:00Z'
            },
            {
              'id' => 'file_def456',
              'type' => 'file',
              'filename' => 'document2.txt',
              'mime_type' => 'text/plain',
              'size_bytes' => 200,
              'created_at' => '2023-01-02T12:00:00Z'
            }
          ]
        }
      end

      it 'returns an array of FileResponse objects' do
        file_responses = described_class.for(data)
        expect(file_responses).to be_an(Array)
        expect(file_responses.count).to eq(2)
        expect(file_responses.first).to be_an_instance_of(Anthropic::FileResponse)
        expect(file_responses.first.filename).to eq('document1.pdf')
        expect(file_responses.last.filename).to eq('document2.txt')
      end
    end
  end

  describe '#file?' do
    context 'when type is "file"' do
      let(:file_response) { described_class.new(type: 'file') }

      it 'returns true' do
        expect(file_response.file?).to be true
      end
    end

    context 'when type is not "file"' do
      let(:file_response) { described_class.new(type: 'message') }

      it 'returns false' do
        expect(file_response.file?).to be false
      end
    end
  end

  describe 'attribute defaults' do
    it 'sets downloadable to false by default' do
      file_response = described_class.new
      expect(file_response.downloadable).to be false
    end

    it 'allows downloadable to be set to true' do
      file_response = described_class.new(downloadable: true)
      expect(file_response.downloadable).to be true
    end
  end
end
