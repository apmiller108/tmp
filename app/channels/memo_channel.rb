class MemoChannel < ApplicationCable::Channel
  def subscribed
    memos = Memo.where(id: params[:memo_ids])
    memos.each { |memo| stream_for memo }
  end

  def unsubscribed
    memos = Memo.where(id: params[:memo_ids])
    memos.each { |memo| stop_stream_for memo }
  end
end
