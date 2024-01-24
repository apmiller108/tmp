require 'rails_helper'

RSpec.describe TranscriptionSummaryJob, type: :job do
  subject(:job) { described_class.new }

  let(:user) { build_stubbed :user }
  let(:summary) { build_stubbed :summary, content: 'summary content ' }
  let(:transcription) { build_stubbed :transcription, summary: }
  let(:transcriptions) { Transcription.none }
  let(:llm_service) { instance_double(LLMService) }
  let(:invoke_model_stream_response) do
    instance_double LLMService::AWS::Client::InvokeModelStreamResponse,
                    content: 'response content', final_chunk?: final_chunk?
  end
  let(:final_chunk?) { false }
  let(:prompt) { 'transcription summary prompt' }
  let(:transcription_summary_component) { instance_double(TranscriptionSummaryComponent) }

  before do
    allow(User).to receive(:find).and_return(user)
    allow(user).to receive(:transcriptions).and_return(transcriptions)
    allow(transcriptions).to receive(:find).with(transcription.id).and_return(transcription)
    allow(summary).to receive(:in_progress!)
    allow(summary).to receive(:save!)
    allow(LLMService).to receive(:new).and_return(llm_service)
    allow(LLMService).to receive(:summary_prompt_for).with(transcription:).and_return(prompt)
    allow(llm_service).to receive(:invoke_model_stream).with(prompt:).and_yield(invoke_model_stream_response)
    allow(ViewComponentBroadcaster).to receive(:call)
    allow(TranscriptionSummaryComponent).to receive(:new).with(transcription:)
                                                         .and_return(transcription_summary_component)
  end

  it 'sets the summary to in progress' do
    job.perform(user.id, transcription.id)
    expect(summary).to have_received(:in_progress!)
  end

  it 'appends the response to the summary content' do
    job.perform(user.id, transcription.id)
    expect(summary.content).to eq 'summary content response content'
  end

  it 'broadcasts the transcription summary component' do
    job.perform(user.id, transcription.id)
    expect(ViewComponentBroadcaster).to(
      have_received(:call).with(
        [user, TurboStreams::STREAMS[:memos]], component: transcription_summary_component, action: :replace
      )
    )
  end

  context 'with the final chunk' do
    let(:final_chunk?) {  true }

    it 'sets summary to completed status' do
      job.perform(user.id, transcription.id)
      expect(summary.status).to eq Summary.statuses[:completed]
    end

    it 'saves the summary' do
      job.perform(user.id, transcription.id)
      expect(summary).to have_received(:save!)
    end
  end

  context 'with an ActiveRecord::RecordNotFound error' do
    before do
      allow(User).to receive(:find).and_raise ActiveRecord::RecordNotFound
    end

    it 'rescues the error' do
      expect { job.perform(user.id, transcription.id) }.not_to raise_error
    end

    it 'logs a warning' do
      expect(Rails.logger).to(
        receive(:warn).with(
          'TranscriptionSummaryJob: ActiveRecord::RecordNotFound : transcription_id: '\
          "#{transcription.id}; user_id: #{user.id}"
        )
      )
      job.perform(user.id, transcription.id)
    end
  end
end
