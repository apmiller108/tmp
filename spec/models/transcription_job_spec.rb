require 'rails_helper'

RSpec.describe TranscriptionJob, type: :model do
  it 'declares status enum' do
    expect(described_class.statuses).to eq({
      'created' => 'created', 'queued' => 'queued', 'in_progress' => 'in_progress',
      'failed' => 'failed', 'completed' => 'completed'
    })
  end

  describe '.create_for' do
    let(:params) { { transcription_job_name: 'job-name' } }
    let(:job_id) { 'job-id' }
    let(:status) { 'in_progress' }
    let(:active_storage_blob) { create :active_storage_blob }
    let(:transcription_service) do
      instance_double(TranscriptionService, status:, params:, job_id:, blob: active_storage_blob)
    end

    it 'creates a new record with the request params and job id' do
      transcription_job = described_class.create_for(transcription_service:)
      expect(transcription_job.attributes).to(
        include 'vendor_job_id' => job_id,
                'active_storage_blob_id' => active_storage_blob.id,
                'request' => params.stringify_keys,
                'status' => status,
                'response' => nil
      )
    end
  end

  describe '#results' do
    subject(:results) { described_class.new(response:).results }

    let(:response) { JSON.parse(file_fixture('transcription/response_toxicity.json').read) }

    it 'returns the transcript' do
      expect(results).to eq response['results']['transcripts'][0]['transcript']
    end

    context 'when there is no response' do
      subject(:job) { described_class.new.results }

      it { is_expected.to be_nil }
    end
  end
end
