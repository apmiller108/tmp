require 'rails_helper'
require 'aws-sdk-transcribeservice'

RSpec.describe TranscriptionService::AWS::BatchTranscriptionResponse do
  let(:transcription_job_name) { 'job name' }
  let(:transcription_job_status) { 'job status' }
  let(:transcription_job) do
    instance_double(Aws::TranscribeService::Types::TranscriptionJob, transcription_job_name:, transcription_job_status:)
  end
  let(:start_job_response) { double(transcription_job:) }

  subject { described_class.new(start_job_response) }

  describe '#job_id' do
    it 'delegates to transcription_job' do
      expect(subject.job_id).to eq transcription_job_name
    end
  end

  describe '#status' do
    it 'delegates to transcription_job' do
      expect(subject.status).to eq transcription_job_status
    end
  end
end
