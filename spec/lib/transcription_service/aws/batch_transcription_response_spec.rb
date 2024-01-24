require 'rails_helper'
require 'aws-sdk-transcribeservice'

RSpec.describe TranscriptionService::AWS::BatchTranscriptionResponse do
  subject(:response) { described_class.new(start_job_response) }

  let(:transcription_job_name) { 'job name' }
  let(:transcription_job_status) { 'job status' }
  let(:transcription_job) do
    instance_double(Aws::TranscribeService::Types::TranscriptionJob, transcription_job_name:, transcription_job_status:)
  end
  let(:start_job_response) { double(transcription_job:) } # rubocop:disable RSpec/VerifiedDoubles

  describe '#job_id' do
    it 'delegates to transcription_job' do
      expect(response.job_id).to eq transcription_job_name
    end
  end

  describe '#status' do
    aws_statuses = %w[QUEUED IN_PROGRESS FAILED COMPLETED]

    aws_statuses.each do |s|
      it "normalizes #{s} status" do
        allow(transcription_job).to receive(:transcription_job_status).and_return(s)
        expect(response.status).to eq TranscriptionJob.statuses[s.downcase]
      end
    end
  end

  describe '#completed?' do
    subject(:completed?) { described_class.new(start_job_response).completed? }

    context 'when completed' do
      let(:transcription_job_status) { 'COMPLETED' }

      it { is_expected.to be true }
    end

    context 'when not completed' do
      let(:transcription_job_status) { 'IN_PROGRESS' }

      it { is_expected.to be false }
    end
  end
end
