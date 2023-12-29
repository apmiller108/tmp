class TranscriptionDownloadsController < ApplicationController
  def show
    transcription = current_user.transcriptions.find(params[:transcription_id])
    filename = "transcription-#{transcription.active_storage_blob.filename}.txt"
    send_data(transcription.to_text, filename:, disposition: :attachment)
  end
end
