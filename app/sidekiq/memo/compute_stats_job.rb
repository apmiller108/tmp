class Memo
  class ComputeStatsJob
    include Sidekiq::Job

    def perform(memo_id)
      memo = Memo.find(memo_id)
      {}.then { |stats| stats.merge(media_attachment_counts(memo)) }
        .then { |stats| stats.merge(total_attachment_counts(memo)) }
        .then { |stats| memo.update!(**stats) }
      ViewComponentBroadcaster.call(
        [memo.user, TurboStreams::STREAMS[:memos]],
        component: MemoCardComponent.new(memo:),
        action: :replace
      )
    end

    private

    def media_attachment_counts(memo)
      memo.content_attachment_counts.each_with_object(default_counts) do |(content_type, count), counts|
        attachment_count_type = "#{content_type.split('/')[0]}_attachment_count".to_sym
        next unless attachment_count_type.in?(default_counts.keys)

        counts[attachment_count_type] += count
      end
    end

    def total_attachment_counts(memo)
      {
        attachment_count: memo.content_attachment_counts.values.sum
      }
    end

    def default_counts
      { audio_attachment_count: 0, image_attachment_count: 0, video_attachment_count: 0 }
    end
  end
end
