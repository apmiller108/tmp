class Memo
  class ComputeStatsJob
    include Sidekiq::Job

    def perform(memo_id)
      memo = Memo.find(memo_id)
      attachment_count_by_content_type = memo.content.blob_count_by_content_type

      stats = attachment_count_by_content_type.each_with_object(default_counts) do |(content_type, count), counts|
        type = "#{content_type.split('/')[0]}_attachment_count".to_sym
        counts[type] += count if type.in?(default_counts.keys)
      end

      stats[:attachment_count] = attachment_count_by_content_type.values.sum
    end

    private

    def default_counts
      { audio_attachment_count: 0, image_attachment_count: 0, video_attachment_count: 0 }
    end
  end
end
