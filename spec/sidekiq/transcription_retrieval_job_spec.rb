require 'rails_helper'

RSpec.describe TranscriptionRetrievalJob, type: :job do
  subject(:job) { decribed_class.new }

  let(:transcription_job) { build_stubbed :transcription_job, status: }
  let(:status) { TranscriptionJob.statuses }

  it { expect(described_class).to have_valid_sidekiq_options }

  describe '#perform' do
    before do
      allow(TranscriptionJob).to receive(:find).and_return(transcription_job)
    end
  end
end
