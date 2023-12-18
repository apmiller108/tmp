require 'rails_helper'

describe TranscriptionService do
  let(:client) { double('TranscriptionClient', batch_transcribe: nil) }
  let(:blob) { build_stubbed :active_storage_blob }

  describe '.batch_transcribe' do
    subject(:batch_transcribe) { described_class.batch_transcribe(client, blob) }

    it 'delegates to the client' do
      batch_transcribe
      expect(client).to have_received(:batch_transcribe).with(blob)
    end
  end
end
