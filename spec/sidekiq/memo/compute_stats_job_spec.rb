require 'rails_helper'

RSpec.describe Memo::ComputeStatsJob, type: :job do
  describe '#perform' do
    let(:memo) { create :memo }
    let(:images) { create_list(:active_storage_blob, 2, content_type: 'image/png') }
    let(:audios) { create_list(:active_storage_blob, 1, content_type: 'audio/mp3') }
    let(:videos) { create_list(:active_storage_blob, 3, content_type: 'video/mp4') }
    let(:other) { create(:active_storage_blob, content_type: 'foo/bar') }

    before do
      memo.rich_text_content.embeds_blobs << images
      memo.rich_text_content.embeds_blobs << audios
      memo.rich_text_content.embeds_blobs << videos
      memo.rich_text_content.embeds_blobs << other
      allow(ViewComponentBroadcaster).to receive(:call)
    end

    it 'updates the memo attachment counters cache columns' do
      expect { described_class.new.perform(memo.id) }.to change {
        memo.reload.attributes.slice(
          'image_attachment_count',
          'video_attachment_count',
          'audio_attachment_count',
          'attachment_count'
        )
      }.from({ 'image_attachment_count' => 0,
               'video_attachment_count' => 0,
               'audio_attachment_count' => 0,
               'attachment_count' => 0 })
       .to({ 'image_attachment_count' => 2,
             'video_attachment_count' => 3,
             'audio_attachment_count' => 1,
             'attachment_count' => 7 })
    end

    it 'broadcasts the MemoCardComponent' do
      described_class.new.perform(memo.id)
      expect(ViewComponentBroadcaster).to(
        have_received(:call).with(
          [memo.user, TurboStreams::STREAMS[:memos]],
          component: kind_of(MemoCardComponent),
          action: :replace
        )
      )
    end
  end
end
