class Memo
  class ComputeStatsJob
    include Sidekiq::Job

    def perform(memo_id)
      # memo = Memo.find(memo_id)
      # memo.compute_stats!
    end
  end
end
