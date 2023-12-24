require 'rails_helper'

RSpec.describe TranscriptionStatusCheckJob, type: :job do
  describe '#perform' do
    it 'bulk enqueue retrieval jobs for unfinished jobs' do
      ids = 1.upto(5).to_a
      relation = TranscriptionJob.none
      allow(relation).to receive(:ids).and_return(ids)
      allow(TranscriptionJob).to receive(:unfinished).and_return relation

      expect(Sidekiq::Client).to(
        receive(:push_bulk)
          .with('class' => TranscriptionRetrievalJob, 'args' => ids.map { |i| [i] })
      )
      described_class.new.perform
    end
  end
end
