require 'rails_helper'

RSpec.describe TranscribableContentHandlerJob, type: :job do
  let(:blob_relation) { ActiveStorage::Blob.none }
  let(:blob_ids) { [1, 2, 3] }
  let(:memo_id) { 99 }

  before do
    allow(ActiveStorage::Blob).to receive(:not_transcribed_for).with(memo_id:).and_return(blob_relation)
    allow(blob_relation).to receive(:ids).and_return(blob_ids)
    allow(Sidekiq::Client).to receive(:push_bulk)
  end

  it 'bulk enqueues the TranscribeAudioJob' do
    described_class.new.perform(memo_id)
    expect(Sidekiq::Client).to(
      have_received(:push_bulk)
        .with('class' => TranscribeAudioJob, 'args' => blob_ids.map { |id| [id] })
    )
  end
end
