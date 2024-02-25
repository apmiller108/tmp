class MemoChannel < ApplicationCable::Channel
  # NOTE: This channel isn't being used yet. See also memos_controller.js which
  # creates the subscriptions
  def subscribed
    memos = Memo.where(id: params[:memo_ids])
    memos.each { |memo| stream_for memo }
  end

  def unsubscribed
    memos = Memo.where(id: params[:memo_ids])
    memos.each { |memo| stop_stream_for memo }
  end
end
