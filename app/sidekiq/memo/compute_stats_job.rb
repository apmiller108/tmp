class Memo
  class ComputeStatsJob
    include Sidekiq::Job

    def perform(memo_id)
      memo = Memo.find(memo_id)
      blob_content_type_counts = memo.content.embeds_blobs.group(:content_type).count

      stats = blob_content_type_counts.each_with_object(default_counts) do |(content_type, count), counts|
        type = "#{content_type.split('/')[0]}_attachment_count".to_sym
        counts[type] += count if type.in?(default_counts.keys)
      end

      stats[:attachment_count] = blob_content_type_counts.values.sum
    end

    private

    def default_counts
      { audio_attachment_count: 0, image_attachment_count: 0, video_attachment_count: 0 }
    end
  end
end
