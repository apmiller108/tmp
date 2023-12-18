require 'rails_helper'

describe TranscriptionService::AwsClient do
  describe '#initialize' do
    it 'sets the aws config' do
      client = described_class.new
      expect(client.instance_variable_get(:@config)).to eq Rails.application.credentials.fetch(:aws)
    end

    it 'collects and sets the options' do
      options = { opt1: 1, opt2: 2 }
      client = described_class.new(**options)
      expect(client.instance_variable_get(:@options)).to eq options
    end
  end

  describe '#batch_transcription' do
    subject(:client) { described_class.new(**options) }

    let(:blob) { build_stubbed :active_storage_blob }
    let(:aws_lib_client) { instance_double(Aws::TranscribeService::Client) }
    let(:aws_credentials) { instance_double(Aws::Credentials) }
    let(:job_params) { { a: 1 } }
    let(:options) { {} }

    before do
      allow(Aws::Credentials).to(
        receive(:new).with(Rails.application.credentials.dig(:aws, :access_key_id),
                           Rails.application.credentials.dig(:aws, :secret_access_key))
                     .and_return(aws_credentials)
      )
      allow(Aws::TranscribeService::Client).to(
        receive(:new).with(region: Rails.application.credentials.dig(:aws, :region),
                           credentials: aws_credentials)
                     .and_return(aws_lib_client)
      )
      allow(TranscriptionService::AwsTranscriptionJobParams).to receive(:for).and_return(job_params)
      allow(aws_lib_client).to receive(:start_transcription_job)
      subject.batch_transcribe(blob)
    end

    it 'passes the proper args to the job params' do
      expect(TranscriptionService::AwsTranscriptionJobParams).to have_received(:for).with(blob:)
    end

    it 'starts an aws transcription job with the job params params' do
      expect(aws_lib_client).to have_received(:start_transcription_job).with(job_params)
    end

    context 'with the toxicity_detection option' do
      let(:options) { { toxicity_detection: true } }

      it 'passes the proper args to the job params' do
        expect(TranscriptionService::AwsTranscriptionJobParams).to have_received(:for).with(blob:, **options)
      end

      it 'starts an aws transcription job with the job params' do
        expect(aws_lib_client).to have_received(:start_transcription_job).with(job_params)
      end
    end
  end
end
