# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlobComponent, type: :component do
  subject { page }

  let(:component) { described_class.new(blob: attachment, in_gallery:) }
  let(:representation) { Faker::Internet.url }
  let(:url) { Faker::Internet.url }
  let(:audio?) { false }
  let(:representable?) { false }
  let(:attachment) { ActionText::Attachment.from_attachable(blob, caption:) }
  let(:blob) { build_stubbed :active_storage_blob, id: 1 }
  let(:caption) { nil }
  let(:in_gallery) { false }

  before do
    allow(attachment).to receive(:audio?).and_return(audio?)
    allow(attachment).to receive(:representable?).and_return(representable?)
    allow(attachment).to receive(:representation).and_return(representation)
    allow(attachment).to receive(:caption).and_return(caption)
    allow(attachment).to receive(:url).and_return(url)
    render_inline(component)
  end

  context 'when blob is representable' do
    let(:representable?) { true }

    it { is_expected.to have_css "img[src='#{representation}']" }

    it 'uses the default size' do
      expect(attachment).to have_received(:representation).with(resize_to_limit: described_class::DEFAULT_IMAGE_SIZE)
    end

    it 'displays the default caption' do
      figcaption = page.find('figcaption')
      expect(figcaption).to have_text "#{blob.filename}#{ActiveSupport::NumberHelper.number_to_human_size(blob.byte_size)}"
    end

    context 'with a caption' do
      let(:caption) { 'Caption' }

      it 'displays the caption' do
        figcaption = page.find('figcaption')
        expect(figcaption).to have_text caption
      end
    end

    context 'when in_gallery' do
      let(:in_gallery) { true }

      it 'uses the smaller size' do
        expect(attachment).to have_received(:representation).with(resize_to_limit: described_class::GALLERY_IMAGE_SIZE)
      end
    end
  end

  context 'when the blob is audio' do
    let(:audio?) { true }
    let(:url) { 'http://example.com/sample.wav' }
    let(:transcription) { build_stubbed :transcription }

    it { is_expected.to have_css 'audio' }
    it { is_expected.to have_css "source[src='#{url}'][type='#{blob.content_type}']" }
    it { is_expected.to have_css '#transcription' }

    context 'with a transcription_job' do
      let(:blob) { build_stubbed :active_storage_blob, id: 1, transcription_job: }
      let(:status) { TranscriptionJob.statuses[:in_progress] }
      let(:transcription_job) { build_stubbed :transcription_job, status: }

      it 'shows the transcription status button' do
        expect(page).to have_css("button[id='transcription_job_#{transcription_job.id}']", text: 'Transcription in progress')
      end
    end

    context 'with a completed transcription' do
      let(:blob) { build_stubbed :active_storage_blob, id: 1, transcription_job:, transcription: }
      let(:transcription_job) { build_stubbed :transcription_job, :completed, transcription: }
      let(:transcription) { build_stubbed :transcription }

      it 'shows the transcript' do
        expect(page).to have_content(transcription.content)
      end
    end
  end
end
